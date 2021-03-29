function [AnalysisResults] = PowerSpec_Saporin(rootFolder,saveFigs,delim,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figure panel 7 for Turner_Gheres_Proctor_Drew
%________________________________________________________________________________________________________________________

% colorBlack = [(0/256),(0/256),(0/256)];
% colorGrey = [(209/256),(211/256),(212/256)];
% colorRfcAwake = [(0/256),(64/256),(64/256)];
% colorRfcNREM = [(0/256),(174/256),(239/256)];
% colorRfcREM = [(190/256),(30/256),(45/256)];
colorRest = [(0/256),(166/256),(81/256)];
colorWhisk = [(31/256),(120/256),(179/256)];
% colorStim = [(255/256),(28/256),(206/256)];
colorNREM = [(191/256),(0/256),(255/256)];
colorREM = [(254/256),(139/256),(0/256)];
colorAlert = [(255/256),(191/256),(0/256)];
colorAsleep = [(0/256),(128/256),(255/256)];
colorAll = [(183/256),(115/256),(51/256)];
% colorIso = [(0/256),(256/256),(256/256)];
%% set-up and process data
animalIDs = {'T141','T155','T156','T157','T142','T144','T159','T172','T150','T165','T166'};
C57BL6J_IDs = {'T141','T155','T156','T157'};
SSP_SAP_IDs = {'T142','T144','T159','T172'};
Blank_SAP_IDs = {'T150','T165','T166'};
treatments = {'C57BL6J','SSP_SAP','Blank_SAP'};
behavFields = {'Rest','NREM','REM','Awake','Sleep','All'};
behavFields2 = {'Rest','NREM','REM','Awake','All'};
behavFields3 = {'Rest','Whisk','NREM','REM','Awake','Sleep','All'};
dataTypes = {'CBV_HbT','gammaBandPower'};
%% power spectra during different behaviors
% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    animalID = animalIDs{1,aa};
    % recognize treatment based on animal group
    if ismember(animalID,C57BL6J_IDs) == true
        treatment = 'C57BL6J';
    elseif ismember(animalIDs{1,aa},SSP_SAP_IDs) == true
        treatment = 'SSP_SAP';
    elseif ismember(animalIDs{1,aa},Blank_SAP_IDs) == true
        treatment = 'Blank_SAP';
    end
    for bb = 1:length(behavFields)
        behavField = behavFields{1,bb};
        for cc = 1:length(dataTypes)
            dataType = dataTypes{1,cc};
            % pre-allocate necessary variable fields
            data.(treatment).(behavField).dummCheck = 1;
            if isfield(data.(treatment).(behavField),dataType) == false
                data.(treatment).(behavField).(dataType).adjLH.S = [];
                data.(treatment).(behavField).(dataType).adjLH.f = [];
                data.(treatment).(behavField).(dataType).adjRH.S = [];
                data.(treatment).(behavField).(dataType).adjRH.f = [];
            end
            data.(treatment).(behavField).(dataType).adjLH.S = cat(2,data.(treatment).(behavField).(dataType).adjLH.S,AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjLH.S);
            data.(treatment).(behavField).(dataType).adjLH.f = cat(1,data.(treatment).(behavField).(dataType).adjLH.f,AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjLH.f);
            data.(treatment).(behavField).(dataType).adjRH.S = cat(2,data.(treatment).(behavField).(dataType).adjRH.S,AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjRH.S);
            data.(treatment).(behavField).(dataType).adjRH.f = cat(1,data.(treatment).(behavField).(dataType).adjRH.f,AnalysisResults.(animalID).PowerSpectra.(behavField).(dataType).adjRH.f);
        end
    end
end
% find the peak of the resting PSD for each animal/hemisphere
for aa = 1:length(treatments)
    treatment = treatments{1,aa};
    for cc = 1:length(dataTypes)
        dataType = dataTypes{1,cc};
        for ee = 1:size(data.(treatment).Rest.(dataType).adjLH.S,2)
            data.(treatment).baseline.(dataType).LH(ee,1) = max(data.(treatment).Rest.(dataType).adjLH.S(:,ee));
            data.(treatment).baseline.(dataType).RH(ee,1) = max(data.(treatment).Rest.(dataType).adjRH.S(:,ee));
        end
    end
end
% DC-shift each animal/hemisphere/behavior PSD with respect to the resting peak
for aa = 1:length(treatments)
    treatment = treatments{1,aa};
    for dd = 1:length(behavFields)
        behavField = behavFields{1,dd};
        for jj = 1:length(dataTypes)
            dataType = dataTypes{1,jj};
            for ee = 1:size(data.(treatment).(behavField).(dataType).adjLH.S,2)
                data.(treatment).(behavField).(dataType).adjLH.normS(:,ee) = (data.(treatment).(behavField).(dataType).adjLH.S(:,ee))*(1/(data.(treatment).baseline.(dataType).LH(ee,1)));
                data.(treatment).(behavField).(dataType).adjRH.normS(:,ee) = (data.(treatment).(behavField).(dataType).adjRH.S(:,ee))*(1/(data.(treatment).baseline.(dataType).RH(ee,1)));
            end
        end
    end
end
% take mean/StD of S/f
for aa = 1:length(treatments)
    treatment = treatments{1,aa};
    for h = 1:length(behavFields)
        behavField = behavFields{1,h};
        for jj = 1:length(dataTypes)
            dataType = dataTypes{1,jj};
            data.(treatment).(behavField).(dataType).adjLH.meanCortS = mean(data.(treatment).(behavField).(dataType).adjLH.normS,2);
            data.(treatment).(behavField).(dataType).adjLH.stdCortS = std(data.(treatment).(behavField).(dataType).adjLH.normS,0,2);
            data.(treatment).(behavField).(dataType).adjLH.meanCortf = mean(data.(treatment).(behavField).(dataType).adjLH.f,1);
            data.(treatment).(behavField).(dataType).adjRH.meanCortS = mean(data.(treatment).(behavField).(dataType).adjRH.normS,2);
            data.(treatment).(behavField).(dataType).adjRH.stdCortS = std(data.(treatment).(behavField).(dataType).adjRH.normS,0,2);
            data.(treatment).(behavField).(dataType).adjRH.meanCortf = mean(data.(treatment).(behavField).(dataType).adjRH.f,1);
        end
    end
end


figure;
%% [7a] power spectra of gamma-band power during different arousal-states
sgtitle('\DeltaHbT (\muM) cortical power spectra')
ax1 = subplot(3,4,1);
p1 = loglog(data.C57BL6J.Rest.CBV_HbT.adjLH.meanCortf,data.C57BL6J.Rest.CBV_HbT.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
p2 = loglog(data.Blank_SAP.Rest.CBV_HbT.adjLH.meanCortf,data.Blank_SAP.Rest.CBV_HbT.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
p3 = loglog(data.SSP_SAP.Rest.CBV_HbT.adjLH.meanCortf,data.SSP_SAP.Rest.CBV_HbT.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Rest] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([1/10,0.5])
set(gca,'box','off')

ax2 = subplot(3,4,2);
loglog(data.C57BL6J.Rest.CBV_HbT.adjRH.meanCortf,data.C57BL6J.Rest.CBV_HbT.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Rest.CBV_HbT.adjRH.meanCortf,data.Blank_SAP.Rest.CBV_HbT.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Rest.CBV_HbT.adjRH.meanCortf,data.SSP_SAP.Rest.CBV_HbT.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Rest] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([1/10,0.5])
set(gca,'box','off')

ax3 = subplot(3,4,3);
loglog(data.C57BL6J.NREM.CBV_HbT.adjLH.meanCortf,data.C57BL6J.NREM.CBV_HbT.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.NREM.CBV_HbT.adjLH.meanCortf,data.Blank_SAP.NREM.CBV_HbT.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.NREM.CBV_HbT.adjLH.meanCortf,data.SSP_SAP.NREM.CBV_HbT.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[NREM] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([1/30,0.5])
set(gca,'box','off')

ax4 = subplot(3,4,4);
loglog(data.C57BL6J.NREM.CBV_HbT.adjRH.meanCortf,data.C57BL6J.NREM.CBV_HbT.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.NREM.CBV_HbT.adjRH.meanCortf,data.Blank_SAP.NREM.CBV_HbT.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.NREM.CBV_HbT.adjRH.meanCortf,data.SSP_SAP.NREM.CBV_HbT.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[NREM] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([1/30,0.5])
set(gca,'box','off')


ax5 = subplot(3,4,5);
loglog(data.C57BL6J.REM.CBV_HbT.adjLH.meanCortf,data.C57BL6J.REM.CBV_HbT.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.REM.CBV_HbT.adjLH.meanCortf,data.Blank_SAP.REM.CBV_HbT.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.REM.CBV_HbT.adjLH.meanCortf,data.SSP_SAP.REM.CBV_HbT.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[REM] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([1/60,0.5])
set(gca,'box','off')

ax6 = subplot(3,4,6);
loglog(data.C57BL6J.REM.CBV_HbT.adjRH.meanCortf,data.C57BL6J.REM.CBV_HbT.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.REM.CBV_HbT.adjRH.meanCortf,data.Blank_SAP.REM.CBV_HbT.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.REM.CBV_HbT.adjRH.meanCortf,data.SSP_SAP.REM.CBV_HbT.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[REM] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([1/60,0.5])
set(gca,'box','off')


ax7 = subplot(3,4,7);
loglog(data.C57BL6J.Awake.CBV_HbT.adjLH.meanCortf,data.C57BL6J.Awake.CBV_HbT.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Awake.CBV_HbT.adjLH.meanCortf,data.Blank_SAP.Awake.CBV_HbT.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Awake.CBV_HbT.adjLH.meanCortf,data.SSP_SAP.Awake.CBV_HbT.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Alert] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([0.003,0.5])
set(gca,'box','off')

ax8 = subplot(3,4,8);
loglog(data.C57BL6J.Awake.CBV_HbT.adjRH.meanCortf,data.C57BL6J.Awake.CBV_HbT.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Awake.CBV_HbT.adjRH.meanCortf,data.Blank_SAP.Awake.CBV_HbT.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Awake.CBV_HbT.adjRH.meanCortf,data.SSP_SAP.Awake.CBV_HbT.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Alert] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([0.003,0.5])
set(gca,'box','off')

ax9 = subplot(3,4,9);
loglog(data.C57BL6J.Sleep.CBV_HbT.adjLH.meanCortf,data.C57BL6J.Sleep.CBV_HbT.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Sleep.CBV_HbT.adjLH.meanCortf,data.Blank_SAP.Sleep.CBV_HbT.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Sleep.CBV_HbT.adjLH.meanCortf,data.SSP_SAP.Sleep.CBV_HbT.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Asleep] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([0.003,0.5])
set(gca,'box','off')

ax10 = subplot(3,4,10);
loglog(data.C57BL6J.Sleep.CBV_HbT.adjRH.meanCortf,data.C57BL6J.Sleep.CBV_HbT.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Sleep.CBV_HbT.adjRH.meanCortf,data.Blank_SAP.Sleep.CBV_HbT.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Sleep.CBV_HbT.adjRH.meanCortf,data.SSP_SAP.Sleep.CBV_HbT.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Asleep] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([0.003,0.5])
set(gca,'box','off')

ax11 = subplot(3,4,11);
loglog(data.C57BL6J.All.CBV_HbT.adjLH.meanCortf,data.C57BL6J.All.CBV_HbT.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.All.CBV_HbT.adjLH.meanCortf,data.Blank_SAP.All.CBV_HbT.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.All.CBV_HbT.adjLH.meanCortf,data.SSP_SAP.All.CBV_HbT.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[All] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([0.003,0.5])
set(gca,'box','off')

ax12 = subplot(3,4,12);
loglog(data.C57BL6J.All.CBV_HbT.adjRH.meanCortf,data.C57BL6J.All.CBV_HbT.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.All.CBV_HbT.adjRH.meanCortf,data.Blank_SAP.All.CBV_HbT.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.All.CBV_HbT.adjRH.meanCortf,data.SSP_SAP.All.CBV_HbT.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[All] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([0.003,0.5])
set(gca,'box','off')

linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10,ax11,ax12],'y')


figure;
%% [7a] power spectra of gamma-band power during different arousal-states
sgtitle('Gamma-band [30-100 Hz] cortical power spectra')
ax1 = subplot(3,4,1);
p1 = loglog(data.C57BL6J.Rest.gammaBandPower.adjLH.meanCortf,data.C57BL6J.Rest.gammaBandPower.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
p2 = loglog(data.Blank_SAP.Rest.gammaBandPower.adjLH.meanCortf,data.Blank_SAP.Rest.gammaBandPower.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
p3 = loglog(data.SSP_SAP.Rest.gammaBandPower.adjLH.meanCortf,data.SSP_SAP.Rest.gammaBandPower.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Rest] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([1/10,0.5])
set(gca,'box','off')

ax2 = subplot(3,4,2);
loglog(data.C57BL6J.Rest.gammaBandPower.adjRH.meanCortf,data.C57BL6J.Rest.gammaBandPower.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Rest.gammaBandPower.adjRH.meanCortf,data.Blank_SAP.Rest.gammaBandPower.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Rest.gammaBandPower.adjRH.meanCortf,data.SSP_SAP.Rest.gammaBandPower.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Rest] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([1/10,0.5])
set(gca,'box','off')

ax3 = subplot(3,4,3);
loglog(data.C57BL6J.NREM.gammaBandPower.adjLH.meanCortf,data.C57BL6J.NREM.gammaBandPower.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.NREM.gammaBandPower.adjLH.meanCortf,data.Blank_SAP.NREM.gammaBandPower.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.NREM.gammaBandPower.adjLH.meanCortf,data.SSP_SAP.NREM.gammaBandPower.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[NREM] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([1/30,0.5])
set(gca,'box','off')

ax4 = subplot(3,4,4);
loglog(data.C57BL6J.NREM.gammaBandPower.adjRH.meanCortf,data.C57BL6J.NREM.gammaBandPower.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.NREM.gammaBandPower.adjRH.meanCortf,data.Blank_SAP.NREM.gammaBandPower.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.NREM.gammaBandPower.adjRH.meanCortf,data.SSP_SAP.NREM.gammaBandPower.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[NREM] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([1/30,0.5])
set(gca,'box','off')


ax5 = subplot(3,4,5);
loglog(data.C57BL6J.REM.gammaBandPower.adjLH.meanCortf,data.C57BL6J.REM.gammaBandPower.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.REM.gammaBandPower.adjLH.meanCortf,data.Blank_SAP.REM.gammaBandPower.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.REM.gammaBandPower.adjLH.meanCortf,data.SSP_SAP.REM.gammaBandPower.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[REM] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([1/60,0.5])
set(gca,'box','off')

ax6 = subplot(3,4,6);
loglog(data.C57BL6J.REM.gammaBandPower.adjRH.meanCortf,data.C57BL6J.REM.gammaBandPower.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.REM.gammaBandPower.adjRH.meanCortf,data.Blank_SAP.REM.gammaBandPower.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.REM.gammaBandPower.adjRH.meanCortf,data.SSP_SAP.REM.gammaBandPower.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[REM] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([1/60,0.5])
set(gca,'box','off')


ax7 = subplot(3,4,7);
loglog(data.C57BL6J.Awake.gammaBandPower.adjLH.meanCortf,data.C57BL6J.Awake.gammaBandPower.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Awake.gammaBandPower.adjLH.meanCortf,data.Blank_SAP.Awake.gammaBandPower.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Awake.gammaBandPower.adjLH.meanCortf,data.SSP_SAP.Awake.gammaBandPower.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Alert] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([0.003,0.5])
set(gca,'box','off')

ax8 = subplot(3,4,8);
loglog(data.C57BL6J.Awake.gammaBandPower.adjRH.meanCortf,data.C57BL6J.Awake.gammaBandPower.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Awake.gammaBandPower.adjRH.meanCortf,data.Blank_SAP.Awake.gammaBandPower.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Awake.gammaBandPower.adjRH.meanCortf,data.SSP_SAP.Awake.gammaBandPower.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Alert] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([0.003,0.5])
set(gca,'box','off')

ax9 = subplot(3,4,9);
loglog(data.C57BL6J.Sleep.gammaBandPower.adjLH.meanCortf,data.C57BL6J.Sleep.gammaBandPower.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Sleep.gammaBandPower.adjLH.meanCortf,data.Blank_SAP.Sleep.gammaBandPower.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Sleep.gammaBandPower.adjLH.meanCortf,data.SSP_SAP.Sleep.gammaBandPower.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Asleep] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([0.003,0.5])
set(gca,'box','off')

ax10 = subplot(3,4,10);
loglog(data.C57BL6J.Sleep.gammaBandPower.adjRH.meanCortf,data.C57BL6J.Sleep.gammaBandPower.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.Sleep.gammaBandPower.adjRH.meanCortf,data.Blank_SAP.Sleep.gammaBandPower.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.Sleep.gammaBandPower.adjRH.meanCortf,data.SSP_SAP.Sleep.gammaBandPower.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[Asleep] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([0.003,0.5])
set(gca,'box','off')

ax11 = subplot(3,4,11);
loglog(data.C57BL6J.All.gammaBandPower.adjLH.meanCortf,data.C57BL6J.All.gammaBandPower.adjLH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.All.gammaBandPower.adjLH.meanCortf,data.Blank_SAP.All.gammaBandPower.adjLH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.All.gammaBandPower.adjLH.meanCortf,data.SSP_SAP.All.gammaBandPower.adjLH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[All] LH (UnRx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
legend([p1,p2,p3],'C57BL6J','Blank-SAP','SSP-SAP')
xlim([0.003,0.5])
set(gca,'box','off')

ax12 = subplot(3,4,12);
loglog(data.C57BL6J.All.gammaBandPower.adjRH.meanCortf,data.C57BL6J.All.gammaBandPower.adjRH.meanCortS,'color',colors('sapphire'),'LineWidth',2);
hold on
loglog(data.Blank_SAP.All.gammaBandPower.adjRH.meanCortf,data.Blank_SAP.All.gammaBandPower.adjRH.meanCortS,'color',colors('north texas green'),'LineWidth',2);
loglog(data.SSP_SAP.All.gammaBandPower.adjRH.meanCortf,data.SSP_SAP.All.gammaBandPower.adjRH.meanCortS,'color',colors('electric purple'),'LineWidth',2);
title('[All] RH (Rx)')
ylabel('Power (a.u.)')
xlabel('Freq (Hz)')
xlim([0.003,0.5])
set(gca,'box','off')

linkaxes([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10,ax11,ax12],'y')

end