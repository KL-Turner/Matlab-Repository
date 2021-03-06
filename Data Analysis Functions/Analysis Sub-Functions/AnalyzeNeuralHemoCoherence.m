function [AnalysisResults] = AnalyzeNeuralHemoCoherence(animalID,group,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the spectral coherence between neural-hemodynamic [HbT] signals (IOS)
%________________________________________________________________________________________________________________________

%% function parameters
dataTypes = {'deltaBandPower','thetaBandPower','alphaBandPower','betaBandPower','gammaBandPower'};
hemDataTypes = {'adjLH','adjRH'};
modelType = 'Forest';
params.minTime.Rest = 10;
params.minTime.NREM = 30;
params.minTime.REM = 60;
%% only run analysis for valid animal IDs
dataLocation = [rootFolder '\' group '\' animalID '\Bilateral Imaging\'];
cd(dataLocation)
% character list of all ProcData file IDs
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFileIDs = char(procDataFiles);
% find and load RestData.mat struct
restDataFileStruct = dir('*_RestData.mat');
restDataFile = {restDataFileStruct.name}';
restDataFileID = char(restDataFile);
load(restDataFileID,'-mat')
% find and load manual baseline event information
manualBaselineFileStruct = dir('*_ManualBaselineFileList.mat');
manualBaselineFile = {manualBaselineFileStruct.name}';
manualBaselineFileID = char(manualBaselineFile);
load(manualBaselineFileID,'-mat')
% find and load RestingBaselines.mat struct
baselineDataFileStruct = dir('*_RestingBaselines.mat');
baselineDataFile = {baselineDataFileStruct.name}';
baselineDataFileID = char(baselineDataFile);
load(baselineDataFileID,'-mat')
% find and load SleepData.mat struct
sleepDataFileStruct = dir('*_SleepData.mat');
sleepDataFile = {sleepDataFileStruct.name}';
sleepDataFileID = char(sleepDataFile);
load(sleepDataFileID,'-mat')
% find and load Forest_ScoringResults.mat struct
forestScoringResultsFileID = [animalID '_Forest_ScoringResults.mat'];
load(forestScoringResultsFileID,'-mat')
% lowpass filter
samplingRate = RestData.CBV_HbT.adjLH.CBVCamSamplingRate;
% [z,p,k] = butter(4,1/(samplingRate/2),'low');
% [sos,g] = zp2sos(z,p,k);
% criteria for resting
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {params.minTime.Rest};
RestPuffCriteria.Fieldname = {'puffDistances'};
RestPuffCriteria.Comparison = {'gt'};
RestPuffCriteria.Value = {5};
% go through each valid data type for arousal-based coherence analysis
for zzz = 1:length(hemDataTypes)
    hemDataType = hemDataTypes{1,zzz};
    for aa = 1:length(dataTypes)
        dataType = dataTypes{1,aa};
        %% analyze neural-hemo coherence during periods of rest
        % pull data from RestData.mat structure
        [restLogical] = FilterEvents_IOS(RestData.CBV_HbT.(hemDataType),RestCriteria);
        [puffLogical] = FilterEvents_IOS(RestData.CBV_HbT.(hemDataType),RestPuffCriteria);
        combRestLogical = logical(restLogical.*puffLogical);
        restFileIDs = RestData.CBV_HbT.(hemDataType).fileIDs(combRestLogical,:);
        restEventTimes = RestData.CBV_HbT.(hemDataType).eventTimes(combRestLogical,:);
        restDurations = RestData.CBV_HbT.(hemDataType).durations(combRestLogical,:);
        HbT_unstimRestingData = RestData.CBV_HbT.(hemDataType).data(combRestLogical,:);
        Gamma_unstimRestingData = RestData.(['cortical_' hemDataType(4:5)]).(dataType).NormData(combRestLogical,:);
        % keep only the data that occurs within the manually-approved awake regions
        [HbT_finalRestData,~,~,~] = RemoveInvalidData_IOS(HbT_unstimRestingData,restFileIDs,restDurations,restEventTimes,ManualDecisions);
        [Gamma_finalRestData,~,~,~] = RemoveInvalidData_IOS(Gamma_unstimRestingData,restFileIDs,restDurations,restEventTimes,ManualDecisions);
        clear HbT_ProcRestData Gamma_ProcRestData
        % filter, detrend, and truncate data to minimum length to match events
        for bb = 1:length(HbT_finalRestData)
            if length(HbT_finalRestData{bb,1}) < params.minTime.Rest*samplingRate
                restChunkSampleDiff = params.minTime.Rest*samplingRate - length(HbT_finalRestData{bb,1});
                HbT_restPad = (ones(1,restChunkSampleDiff))*HbT_finalRestData{bb,1}(end);
                Gamma_restPad = (ones(1,restChunkSampleDiff))*Gamma_finalRestData{bb,1}(end);
                HbT_ProcRestData{bb,1} = horzcat(HbT_finalRestData{bb,1},HbT_restPad); %#ok<*AGROW>
                Gamma_ProcRestData{bb,1} = horzcat(Gamma_finalRestData{bb,1},Gamma_restPad);
                % HbT_ProcRestData{bb,1} = filtfilt(sos,g,detrend(HbT_ProcRestData{bb,1},'constant'));
                % Gamma_ProcRestData{bb,1} = filtfilt(sos,g,detrend(Gamma_ProcRestData{bb,1},'constant'));
                HbT_ProcRestData{bb,1} = detrend(HbT_ProcRestData{bb,1},'constant');
                Gamma_ProcRestData{bb,1} = detrend(Gamma_ProcRestData{bb,1},'constant');
            else
                % HbT_ProcRestData{bb,1} = filtfilt(sos,g,detrend(HbT_finalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant'));
                % Gamma_ProcRestData{bb,1} = filtfilt(sos,g,detrend(Gamma_finalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant'));
                HbT_ProcRestData{bb,1} = detrend(HbT_finalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant');
                Gamma_ProcRestData{bb,1} = detrend(Gamma_finalRestData{bb,1}(1:(params.minTime.Rest*samplingRate)),'constant');
            end
        end
        % input data as time(1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        HbT_restData = zeros(length(HbT_ProcRestData{1,1}),length(HbT_ProcRestData));
        Gamma_restData = zeros(length(Gamma_ProcRestData{1,1}),length(Gamma_ProcRestData));
        for cc = 1:length(HbT_ProcRestData)
            HbT_restData(:,cc) = HbT_ProcRestData{cc,1};
            Gamma_restData(:,cc) = Gamma_ProcRestData{cc,1};
        end
        % parameters for coherencyc - information available in function
        params.tapers = [3,5];   % Tapers [n, 2n - 1]
        params.pad = 1;
        params.Fs = samplingRate;
        params.fpass = [0,1];   % Pass band [0, nyquist]
        params.trialave = 1;
        params.err = [2,0.05];
        % calculate the coherence between desired signals
        [C_RestData,~,~,~,~,f_RestData,confC_RestData,~,cErr_RestData] = coherencyc(HbT_restData,Gamma_restData,params);
        % save results
        AnalysisResults.(animalID).NeuralHemoCoherence.Rest.(dataType).(hemDataType).C = C_RestData;
        AnalysisResults.(animalID).NeuralHemoCoherence.Rest.(dataType).(hemDataType).f = f_RestData;
        AnalysisResults.(animalID).NeuralHemoCoherence.Rest.(dataType).(hemDataType).confC = confC_RestData;
        AnalysisResults.(animalID).NeuralHemoCoherence.Rest.(dataType).(hemDataType).cErr = cErr_RestData;
        %% analyze neural-hemo coherence during periods of alert
        zz = 1;
        clear HbT_AwakeData Gamma_AwakeData HbT_ProcAwakeData Gamma_ProcAwakeData
        HbT_AwakeData = [];
        for bb = 1:size(procDataFileIDs,1)
            procDataFileID = procDataFileIDs(bb,:);
            [~,allDataFileDate,allDataFileID] = GetFileInfo_IOS(procDataFileID);
            strDay = ConvertDate_IOS(allDataFileDate);
            scoringLabels = [];
            for cc = 1:length(ScoringResults.fileIDs)
                if strcmp(allDataFileID,ScoringResults.fileIDs{cc,1}) == true
                    scoringLabels = ScoringResults.labels{cc,1};
                end
            end
            % check labels to match arousal state
            if sum(strcmp(scoringLabels,'Not Sleep')) > 144   % 36 bins (180 total) or 3 minutes of sleep
                load(procDataFileID,'-mat')
                puffs = ProcData.data.stimulations.LPadSol;
                % don't include trials with stimulation
                if isempty(puffs) == true
                    HbT_AwakeData{zz,1} = ProcData.data.CBV_HbT.(hemDataType);
                    Gamma_AwakeData{zz,1} = (ProcData.data.(['cortical_' hemDataType(4:5)]).(dataType) - RestingBaselines.manualSelection.(['cortical_' hemDataType(4:5)]).(dataType).(strDay))./RestingBaselines.manualSelection.(['cortical_' hemDataType(4:5)]).(dataType).(strDay);
                    zz = zz + 1;
                end
            end
        end
        % filter and detrend data
        if isempty(HbT_AwakeData) == false
            for bb = 1:length(HbT_AwakeData)
                % HbT_ProcAwakeData{bb,1} = filtfilt(sos,g,detrend(HbT_AwakeData{bb,1},'constant'));
                % Gamma_ProcAwakeData{bb,1} = filtfilt(sos,g,detrend(Gamma_AwakeData{bb,1},'constant'));
                HbT_ProcAwakeData{bb,1} = detrend(HbT_AwakeData{bb,1},'constant');
                Gamma_ProcAwakeData{bb,1} = detrend(Gamma_AwakeData{bb,1},'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            HbT_awakeData = zeros(length(HbT_ProcAwakeData{1,1}),length(HbT_ProcAwakeData));
            Gamma_awakeData = zeros(length(Gamma_ProcAwakeData{1,1}),length(Gamma_ProcAwakeData));
            for cc = 1:length(HbT_ProcAwakeData)
                HbT_awakeData(:,cc) = HbT_ProcAwakeData{cc,1};
                Gamma_awakeData(:,cc) = Gamma_ProcAwakeData{cc,1};
            end
            % calculate the coherence between desired signals
            [C_AwakeData,~,~,~,~,f_AwakeData,confC_AwakeData,~,cErr_AwakeData] = coherencyc(HbT_awakeData,Gamma_awakeData,params);
            % save results
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).C = C_AwakeData;
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).f = f_AwakeData;
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).confC = confC_AwakeData;
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).cErr = cErr_AwakeData;
        else
            % save results
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).C = [];
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).f = [];
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).confC = [];
            AnalysisResults.(animalID).NeuralHemoCoherence.Awake.(dataType).(hemDataType).cErr = [];
        end
        %% analyze neural-hemo coherence during periods of asleep
        zz = 1;
        clear HbT_SleepData Gamma_SleepData HbT_ProcSleepData Gamma_ProcSleepData
        HbT_SleepData = [];
        for bb = 1:size(procDataFileIDs,1)
            procDataFileID = procDataFileIDs(bb,:);
            [~,allDataFileDate,allDataFileID] = GetFileInfo_IOS(procDataFileID);
            strDay = ConvertDate_IOS(allDataFileDate);
            scoringLabels = [];
            for cc = 1:length(ScoringResults.fileIDs)
                if strcmp(allDataFileID,ScoringResults.fileIDs{cc,1}) == true
                    scoringLabels = ScoringResults.labels{cc,1};
                end
            end
            % check labels to match arousal state
            if sum(strcmp(scoringLabels,'Not Sleep')) < 36   % 36 bins (180 total) or 3 minutes of awake
                load(procDataFileID,'-mat')
                puffs = ProcData.data.stimulations.LPadSol;
                % don't include trials with stimulation
                if isempty(puffs) == true
                    HbT_SleepData{zz,1} = ProcData.data.CBV_HbT.(hemDataType);
                    Gamma_SleepData{zz,1} = (ProcData.data.(['cortical_' hemDataType(4:5)]).(dataType) - RestingBaselines.manualSelection.(['cortical_' hemDataType(4:5)]).(dataType).(strDay))./RestingBaselines.manualSelection.(['cortical_' hemDataType(4:5)]).(dataType).(strDay);
                    zz = zz + 1;
                end
            end
        end
        % filter and detrend data
        if isempty(HbT_SleepData) == false
            for bb = 1:length(HbT_SleepData)
                % HbT_ProcSleepData{bb,1} = filtfilt(sos,g,detrend(HbT_SleepData{bb,1},'constant'));
                % Gamma_ProcSleepData{bb,1} = filtfilt(sos,g,detrend(Gamma_SleepData{bb,1},'constant'));
                HbT_ProcSleepData{bb,1} = detrend(HbT_SleepData{bb,1},'constant');
                Gamma_ProcSleepData{bb,1} = detrend(Gamma_SleepData{bb,1},'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            HbT_sleepData = zeros(length(HbT_ProcSleepData{1,1}),length(HbT_ProcSleepData));
            Gamma_sleepData = zeros(length(Gamma_ProcSleepData{1,1}),length(Gamma_ProcSleepData));
            for cc = 1:length(HbT_ProcSleepData)
                HbT_sleepData(:,cc) = HbT_ProcSleepData{cc,1};
                Gamma_sleepData(:,cc) = Gamma_ProcSleepData{cc,1};
            end
            % calculate the coherence between desired signals
            [C_SleepData,~,~,~,~,f_SleepData,confC_SleepData,~,cErr_SleepData] = coherencyc(HbT_sleepData,Gamma_sleepData,params);
            % save results
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).C = C_SleepData;
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).f = f_SleepData;
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).confC = confC_SleepData;
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).cErr = cErr_SleepData;
        else
            % save results
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).C = [];
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).f = [];
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).confC = [];
            AnalysisResults.(animalID).NeuralHemoCoherence.Sleep.(dataType).(hemDataType).cErr = [];
        end
        %% analyze neural-hemo coherence during periods of all data
        zz = 1;
        clear HbT_AllUnstimData Gamma_AllUnstimData HbT_ProcAllUnstimData Gamma_ProcAllUnstimData
        HbT_AllUnstimData = [];
        for bb = 1:size(procDataFileIDs,1)
            procDataFileID = procDataFileIDs(bb,:);
            [~,allUnstimDataFileDate,~] = GetFileInfo_IOS(procDataFileID);
            strDay = ConvertDate_IOS(allUnstimDataFileDate);
            load(procDataFileID,'-mat')
            puffs = ProcData.data.stimulations.LPadSol;
            % don't include trials with stimulation
            if isempty(puffs) == true
                HbT_AllUnstimData{zz,1} = ProcData.data.CBV_HbT.(hemDataType);
                Gamma_AllUnstimData{zz,1} = (ProcData.data.(['cortical_' hemDataType(4:5)]).(dataType) - RestingBaselines.manualSelection.(['cortical_' hemDataType(4:5)]).(dataType).(strDay))./RestingBaselines.manualSelection.(['cortical_' hemDataType(4:5)]).(dataType).(strDay);
                zz = zz + 1;
            end
        end
        % filter and detrend data
        if isempty(HbT_AllUnstimData) == false
            for bb = 1:length(HbT_AllUnstimData)
                % HbT_ProcAllUnstimData{bb,1} = filtfilt(sos,g,detrend(HbT_AllUnstimData{bb,1},'constant'));
                % Gamma_ProcAllUnstimData{bb,1} = filtfilt(sos,g,detrend(Gamma_AllUnstimData{bb,1},'constant'));
                HbT_ProcAllUnstimData{bb,1} = detrend(HbT_AllUnstimData{bb,1},'constant');
                Gamma_ProcAllUnstimData{bb,1} = detrend(Gamma_AllUnstimData{bb,1},'constant');
            end
            % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
            HbT_allUnstimData = zeros(length(HbT_ProcAllUnstimData{1,1}),length(HbT_ProcAllUnstimData));
            Gamma_allUnstimData = zeros(length(Gamma_ProcAllUnstimData{1,1}),length(Gamma_ProcAllUnstimData));
            for cc = 1:length(HbT_ProcAllUnstimData)
                HbT_allUnstimData(:,cc) = HbT_ProcAllUnstimData{cc,1};
                Gamma_allUnstimData(:,cc) = Gamma_ProcAllUnstimData{cc,1};
            end
            % calculate the coherence between desired signals
            [C_AllUnstimData,~,~,~,~,f_AllUnstimData,confC_AllUnstimData,~,cErr_AllUnstimData] = coherencyc(HbT_allUnstimData,Gamma_allUnstimData,params);
            % save results
            AnalysisResults.(animalID).NeuralHemoCoherence.All.(dataType).(hemDataType).C = C_AllUnstimData;
            AnalysisResults.(animalID).NeuralHemoCoherence.All.(dataType).(hemDataType).f = f_AllUnstimData;
            AnalysisResults.(animalID).NeuralHemoCoherence.All.(dataType).(hemDataType).confC = confC_AllUnstimData;
            AnalysisResults.(animalID).NeuralHemoCoherence.All.(dataType).(hemDataType).cErr = cErr_AllUnstimData;
        end
        %% analyze neural-hemo coherence during periods of NREM
        % pull data from SleepData.mat structure
        [HbT_nremData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).NREM.data.CBV_HbT.(hemDataType(4:5)),SleepData.(modelType).NREM.FileIDs,SleepData.(modelType).NREM.BinTimes);
        [Gamma_nremData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).NREM.data.(['cortical_' hemDataType(4:5)]).(dataType),SleepData.(modelType).NREM.FileIDs,SleepData.(modelType).NREM.BinTimes);
        % filter, detrend, and truncate data to minimum length to match events
        for ee = 1:length(HbT_nremData)
            % HbT_nremData{ee,1} = filtfilt(sos,g,detrend(HbT_nremData{ee,1}(1:(params.minTime.NREM*samplingRate)),'constant'));
            % Gamma_nremData{ee,1} = filtfilt(sos,g,detrend(Gamma_nremData{ee,1}(1:(params.minTime.NREM*samplingRate)),'constant'));
            HbT_nremData{ee,1} = detrend(HbT_nremData{ee,1}(1:(params.minTime.NREM*samplingRate)),'constant');
            Gamma_nremData{ee,1} = detrend(Gamma_nremData{ee,1}(1:(params.minTime.NREM*samplingRate)),'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        HbT_nrem = zeros(length(HbT_nremData{1,1}),length(HbT_nremData));
        Gamma_nrem = zeros(length(Gamma_nremData{1,1}),length(Gamma_nremData));
        for ff = 1:length(HbT_nremData)
            HbT_nrem(:,ff) = HbT_nremData{ff,1};
            Gamma_nrem(:,ff) = Gamma_nremData{ff,1};
        end
        % calculate the coherence between desired signals
        [C_nrem,~,~,~,~,f_nrem,confC_nrem,~,cErr_nrem] = coherencyc(HbT_nrem,Gamma_nrem,params);
        % save results
        AnalysisResults.(animalID).NeuralHemoCoherence.NREM.(dataType).(hemDataType).C = C_nrem;
        AnalysisResults.(animalID).NeuralHemoCoherence.NREM.(dataType).(hemDataType).f = f_nrem;
        AnalysisResults.(animalID).NeuralHemoCoherence.NREM.(dataType).(hemDataType).confC = confC_nrem;
        AnalysisResults.(animalID).NeuralHemoCoherence.NREM.(dataType).(hemDataType).cErr = cErr_nrem;
        %% analyze neural-hemo coherence during periods of REM
        % pull data from SleepData.mat structure
        [HbT_remData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).REM.data.CBV_HbT.(hemDataType(4:5)),SleepData.(modelType).REM.FileIDs,SleepData.(modelType).REM.BinTimes);
        [Gamma_remData,~,~] = RemoveStimSleepData_IOS(animalID,SleepData.(modelType).REM.data.(['cortical_' hemDataType(4:5)]).(dataType),SleepData.(modelType).REM.FileIDs,SleepData.(modelType).REM.BinTimes);
        % filter, detrend, and truncate data to minimum length to match events
        for gg = 1:length(HbT_remData)
            % HbT_remData{gg,1} = filtfilt(sos,g,detrend(HbT_remData{gg,1}(1:(params.minTime.REM*samplingRate)),'constant'));
            % Gamma_remData{gg,1} = filtfilt(sos,g,detrend(Gamma_remData{gg,1}(1:(params.minTime.REM*samplingRate)),'constant'));
            HbT_remData{gg,1} = detrend(HbT_remData{gg,1}(1:(params.minTime.REM*samplingRate)),'constant');
            Gamma_remData{gg,1} = detrend(Gamma_remData{gg,1}(1:(params.minTime.REM*samplingRate)),'constant');
        end
        % input data as time (1st dimension, vertical) by trials (2nd dimension, horizontunstimy)
        HbT_rem = zeros(length(HbT_remData{1,1}),length(HbT_remData));
        Gamma_rem = zeros(length(Gamma_remData{1,1}),length(Gamma_remData));
        for hh = 1:length(HbT_remData)
            HbT_rem(:,hh) = HbT_remData{hh,1};
            Gamma_rem(:,hh) = Gamma_remData{hh,1};
        end
        % calculate the coherence between desired signals
        [C_rem,~,~,~,~,f_rem,confC_rem,~,cErr_rem] = coherencyc(HbT_rem,Gamma_rem,params);
        % save results
        AnalysisResults.(animalID).NeuralHemoCoherence.REM.(dataType).(hemDataType).C = C_rem;
        AnalysisResults.(animalID).NeuralHemoCoherence.REM.(dataType).(hemDataType).f = f_rem;
        AnalysisResults.(animalID).NeuralHemoCoherence.REM.(dataType).(hemDataType).confC = confC_rem;
        AnalysisResults.(animalID).NeuralHemoCoherence.REM.(dataType).(hemDataType).cErr = cErr_rem;
    end
end
% save data
cd(rootFolder)
save('AnalysisResults.mat','AnalysisResults','-v7.3')

end
