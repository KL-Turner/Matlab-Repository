function Process2PDataFiles_2P(labviewDataFiles, mscanDataFiles)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Analyze the force sensor and neural bands. Create a threshold for binarized movement/whisking if 
%            one does not already exist.
%________________________________________________________________________________________________________________________
%
%   Inputs: List of LabVIEW and MScan data files.
%
%   Outputs: Saves updates to both files in the current directory.
%
%   Last Revised: March 21st, 2019
%________________________________________________________________________________________________________________________

%% MScan data file analysis
for a = 1:size(mscanDataFiles,1)
    mscanDataFile = mscanDataFiles(a,:);
    load(mscanDataFile);
    % Skip the file if it has already been processed
    if MScanData.notes.checklist.processData == false
        disp(['Analyzing MScan neural bands and analog signals for file number ' num2str(a) ' of ' num2str(size(mscanDataFiles, 1)) '...']); disp(' ');
        animalID = MScanData.notes.animalID;
        imageID = MScanData.notes.imageID;
        date = MScanData.notes.date;
        strDay = ConvertDate_2P(date);
        
        expectedLength = (MScanData.notes.numberOfFrames/MScanData.notes.frameRate)*MScanData.notes.analogSamplingRate;
        %% Process neural data into its various forms.
        % MUA Band [300 - 3000]
        [MScanData.data.muaPower, MScanData.notes.downSampledFs] = ProcessNeuro_2P(MScanData, expectedLength, 'MUA', 'rawNeuralData');
        downSampledFs = MScanData.notes.downSampledFs;

        % Gamma Band [40 - 100]
        [MScanData.data.gammaPower, ~] = ProcessNeuro_2P(MScanData, expectedLength, 'Gam', 'rawNeuralData');
        
        % Beta [13 - 30 Hz]
        [MScanData.data.betaPower, ~] = ProcessNeuro_2P(MScanData, expectedLength, 'Beta', 'rawNeuralData');
        
        % Alpha [8 - 12 Hz]
        [MScanData.data.alphaPower, ~] = ProcessNeuro_2P(MScanData, expectedLength, 'Alpha', 'rawNeuralData');
        
        % Theta [4 - 8 Hz]
        [MScanData.data.thetaPower, ~] = ProcessNeuro_2P(MScanData, expectedLength, 'Theta', 'rawNeuralData');
        
        % Delta [1 - 4 Hz]
        [MScanData.data.deltaPower, ~] = ProcessNeuro_2P(MScanData, expectedLength, 'Delta', 'rawNeuralData');
        
        %% Downsample and binarize the force sensor.
        trimmedForceM = MScanData.data.forceSensor(1:min(expectedLength, length(MScanData.data.forceSensor)));
        
        % Filter then downsample the Force Sensor waveform to desired frequency
        filtThreshold = 20;
        filtOrder = 2;
        [z, p, k] = butter(filtOrder, filtThreshold/(MScanData.notes.analogSamplingRate/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filtForceSensorM = filtfilt(sos, g, trimmedForceM);
        MScanData.data.dsForceSensorM = resample(filtForceSensorM, downSampledFs, MScanData.notes.analogSamplingRate);
        
        % Binarize the force sensor waveform
        threshfile = dir('*_Thresholds.mat');
        if ~isempty(threshfile)
            load(threshfile.name)
        end
        
        [ok] = CheckForThreshold_2P(['binarizedForceSensor_' strDay], animalID);
        
        if ok == 0
            [forceSensorThreshold] = CreateForceSensorThreshold_2P(MScanData.data.dsForceSensorM);
            Thresholds.(['binarizedForceSensor_' strDay]) = forceSensorThreshold;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        MScanData.data.binForceSensorM = BinarizeForceSensor_2P(MScanData.data.dsForceSensorM, Thresholds.(['binarizedForceSensor_' strDay]));
        
        %% EMG
        fpass = [30 300];
        trimmedEMG = (1:min(expectedLength, length(MScanData.data.EMG)));
        [z1, p1, k1] = butter(4, fpass/(MScanData.notes.analogSamplingRate/2));
        [sos1, g1] = zp2sos(z1, p1, k1);
        filtEMG = filtfilt(sos1, g1, trimmedEMG - mean(trimmedEMG));
        [z2, p2, k2] = butter(4, 10/(MScanData.notes.analogSamplingRate/2), 'low');
        [sos2, g2] = zp2sos(z2, p2, k2);
        smoothEMGPower = filtfilt(sos2, g2, filtEMG.^2);
        MScanData.data.dsEMG = max(resample(smoothEMGPower, downSampledFs, MScanData.notes.analogSamplingRate), 0);

        %% Save the data, set checklist to true
        MScanData.notes.checklist.processData = true;
        save([animalID '_' date '_' imageID '_MScanData'], 'MScanData')
    else
        disp([mscanDataFile ' has already been processed. Continuing...']); disp(' ');
    end
end


%% LabVIEW data file analysis
for b = 1:size(labviewDataFiles,1)
    labviewDataFile = labviewDataFiles(b,:);
    load(labviewDataFile);
    if LabVIEWData.notes.checklist.processData == false
        disp(['Analyzing LabVIEW analog signals and whisker angle for file number ' num2str(b) ' of ' num2str(size(labviewDataFiles, 1)) '...']); disp(' ');
        [animalID, hem, fileDate, fileID] = GetFileInfo_2P(labviewDataFile);
        strDay = ConvertDate_2P(fileDate);
        expectedLength = LabVIEWData.notes.trialDuration_Seconds*LabVIEWData.notes.analogSamplingRate_Hz;

        %% Patch and binarize the whisker angle and set the resting angle to zero degrees.
        [patchedWhisk] = PatchWhiskerAngle_2P(LabVIEWData.data.whiskerAngle, LabVIEWData.notes.whiskerCamSamplingRate_Hz, LabVIEWData.notes.trialDuration_Seconds, LabVIEWData.notes.droppedWhiskerCamFrameIndex);
        
        % Create filter for whisking/movement
        downSampledFs = 30;
        filtThreshold = 20;
        filtOrder = 2;
        [z, p, k] = butter(filtOrder, filtThreshold/(LabVIEWData.notes.whiskerCamSamplingRate_Hz/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filteredWhiskers = filtfilt(sos, g, patchedWhisk - mean(patchedWhisk));
        resampledWhisk = resample(filteredWhiskers, downSampledFs, LabVIEWData.notes.whiskerCamSamplingRate_Hz);
        
        % Binarize the whisker waveform (wwf)
        threshfile = dir('*_Thresholds.mat');
        if ~isempty(threshfile)
            load(threshfile.name)
        end
        
        [ok] = CheckForThreshold_2P(['binarizedWhiskersLower_' strDay], animalID);
        
        if ok == 0
            [whiskersThresh1, whiskersThresh2] = CreateWhiskThreshold_2P(resampledWhisk, downSampledFs);
            Thresholds.(['binarizedWhiskersLower_' strDay]) = whiskersThresh1;
            Thresholds.(['binarizedWhiskersUpper_' strDay]) = whiskersThresh2;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        load([animalID '_Thresholds.mat']);
        binWhisk = BinarizeWhiskers_2P(resampledWhisk, downSampledFs, Thresholds.(['binarizedWhiskersLower_' strDay]), Thresholds.(['binarizedWhiskersUpper_' strDay]));
        [linkedBinarizedWhiskers] = LinkBinaryEvents_2P(gt(binWhisk,0), [round(downSampledFs/3), 0]);
        inds = linkedBinarizedWhiskers == 0;
        restAngle = mean(resampledWhisk(inds));
        
        LabVIEWData.data.dsWhiskerAngle = resampledWhisk - restAngle;
        LabVIEWData.data.binWhiskerAngle = binWhisk;
        
        %% Downsample and binarize the force sensor.
        trimmedForceL = LabVIEWData.data.forceSensor(1:min(expectedLength, length(LabVIEWData.data.forceSensor)));
        
        % Filter then downsample the Force Sensor waveform to desired frequency
        [z, p, k] = butter(filtOrder, filtThreshold/(LabVIEWData.notes.analogSamplingRate_Hz/2), 'low');
        [sos, g] = zp2sos(z, p, k);
        filtForceSensorL = filtfilt(sos, g, trimmedForceL);
        
        LabVIEWData.data.dsForceSensorL = resample(filtForceSensorL, downSampledFs, LabVIEWData.notes.analogSamplingRate_Hz);
        
        % Binarize the force sensor waveform
        [ok] = CheckForThreshold_2P(['binarizedForceSensor_' strDay], animalID);
        
        if ok == 0
            [forceSensorThreshold] = CreateForceSensorThreshold_2P(LabVIEWData.data.dsForceSensorL);
            Thresholds.(['binarizedForceSensor_' strDay]) = forceSensorThreshold;
            save([animalID '_Thresholds.mat'], 'Thresholds');
        end
        
        LabVIEWData.data.binForceSensorL = BinarizeForceSensor_2P(LabVIEWData.data.dsForceSensorL, Thresholds.(['binarizedForceSensor_' strDay]));
        
        %% Save the data, set checklist to true
        LabVIEWData.notes.checklist.processData = true;
        save([animalID '_' hem '_' fileID '_LabVIEWData'], 'LabVIEWData')
    else
        disp([labviewDataFile ' has already been processed. Continuing...']); disp(' ');     
    end
end

end

