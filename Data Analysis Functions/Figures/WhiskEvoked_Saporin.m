function [AnalysisResults] = WhiskEvoked_Saporin(rootFolder,saveFigs,delim,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Purpose: Generate figure panel 1-S3 for Turner_Gheres_Proctor_Drew
%________________________________________________________________________________________________________________________

%% set-up
animalIDs = {'T135','T141','T142','T144','T151','T155','T156','T157','T159'};
C57BL6J_IDs = {'T141','T155','T156','T157'};
SSP_SAP_IDs = {'T135','T142','T144','T151','T159'};
Blank_SAP_IDs = {''};
whiskDataTypes = {'ShortWhisks','IntermediateWhisks','LongWhisks'};
hemispheres = {'adjLH','adjRH'};
treatments = {'C57BL6J','Blank_SAP','SSP_SAP'};
data = [];
cortVariables = {'HbT','CBV','cortMUA','cortGam','cortS','cortS_Gam','cortT','cortF','timeVector'};
hipVariables = {'hipMUA','hipGam','hipS','hipS_Gam','hipT','hipF','timeVector'};
%% cd through each animal's directory and extract the appropriate analysis results
for aa = 1:length(animalIDs)
    % recognize treatment based on animal group
    if ismember(animalIDs{1,aa},C57BL6J_IDs) == true
        treatment = 'C57BL6J';
    elseif ismember(animalIDs{1,aa},SSP_SAP_IDs) == true
        treatment = 'SSP_SAP';
    elseif ismember(animalIDs{1,aa},Blank_SAP_IDs) == true
        treatment = 'Blank_SAP';
    end
    % short - intermediate - long whisks
    for bb = 1:length(whiskDataTypes)
        % left, right hemishpere hemo & neural data
        for cc = 1:length(hemispheres)
            % pre-allocate necessary variable fields
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).dummCheck = 1;
            for dd = 1:length(cortVariables)
                if isfield(data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}),cortVariables{1,dd}) == false
                    data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).(cortVariables{1,dd}) = [];
                end
            end
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).HbT = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).HbT,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).CBV_HbT.HbT);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).CBV = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).CBV,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).CBV.CBV);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortMUA = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortMUA,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).MUA.corticalData);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortGam = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortGam,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).Gam.corticalData);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortS = cat(3,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortS,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).LFP.corticalS);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortS_Gam = cat(3,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortS_Gam,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).LFP.corticalS(49:end,20:23));
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortT = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortT,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).LFP.T);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortF = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).cortF,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.(hemispheres{1,cc}).(whiskDataTypes{1,bb}).LFP.F);
            data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).timeVector = cat(1,data.(treatment).(whiskDataTypes{1,bb}).(hemispheres{1,cc}).timeVector,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).timeVector);
        end
        % hippocampal neural data - preallocate necessary variable fields
        data.(treatment).(whiskDataTypes{1,bb}).Hip.dummyCheck = 1;
        for ee = 1:length(hipVariables)
            if isfield(data.(treatment).(whiskDataTypes{1,bb}).Hip,hipVariables{1,ee}) == false
                data.(treatment).(whiskDataTypes{1,bb}).Hip.(hipVariables{1,ee}) = [];
            end
        end
        data.(treatment).(whiskDataTypes{1,bb}).Hip.hipMUA = cat(1,data.(treatment).(whiskDataTypes{1,bb}).Hip.hipMUA,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).MUA.hippocampalData);
        data.(treatment).(whiskDataTypes{1,bb}).Hip.hipGam = cat(1,data.(treatment).(whiskDataTypes{1,bb}).Hip.hipGam,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).Gam.hippocampalData);
        data.(treatment).(whiskDataTypes{1,bb}).Hip.hipS = cat(3,data.(treatment).(whiskDataTypes{1,bb}).Hip.hipS,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).LFP.hippocampalS);
        data.(treatment).(whiskDataTypes{1,bb}).Hip.hipS_Gam = cat(3,data.(treatment).(whiskDataTypes{1,bb}).Hip.hipS_Gam,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).LFP.hippocampalS(49:end,20:23));
        data.(treatment).(whiskDataTypes{1,bb}).Hip.hipT = cat(1,data.(treatment).(whiskDataTypes{1,bb}).Hip.hipT,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).LFP.T);
        data.(treatment).(whiskDataTypes{1,bb}).Hip.hipF = cat(1,data.(treatment).(whiskDataTypes{1,bb}).Hip.hipF,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).LFP.F);
        data.(treatment).(whiskDataTypes{1,bb}).Hip.timeVector = cat(1,data.(treatment).(whiskDataTypes{1,bb}).Hip.timeVector,AnalysisResults.(animalIDs{1,aa}).EvokedAvgs.Whisk.adjLH.(whiskDataTypes{1,bb}).timeVector);
    end
end
%% concatenate the data from the contra and ipsi data
for ff = 1:length(treatments)
    for gg = 1:length(whiskDataTypes)
        for hh = 1:length(hemispheres)
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanHbT = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).HbT,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).stdHbT = std(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).HbT,0,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanCBV = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).CBV,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).stdCBV = std(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).CBV,0,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanCortMUA = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortMUA,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).stdCortMUA = std(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortMUA,0,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanCortGam = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortGam,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).stdCortGam = std(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortGam,0,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanCortS = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortS,3).*100;
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).mean_CortS_Gam = mean(mean(mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortS_Gam.*100,1),2),3);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).std_CortS_Gam = std(mean(mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortS_Gam.*100,1),2),0,3);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanCortT = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortT,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanCortF = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).cortF,1);
            data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).meanTimeVector = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).(hemispheres{1,hh}).timeVector,1);
        end
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.meanHipMUA = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipMUA,1);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.stdHipMUA = std(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipMUA,0,1);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.meanHipGam = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipGam,1);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.stdHipGam = std(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipGam,0,1);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.meanHipS = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipS,3).*100;
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.mean_HipS_Gam = mean(mean(mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipS_Gam.*100,1),2),3);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.std_HipS_Gam = std(mean(mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipS_Gam.*100,1),2),0,3);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.meanHipT = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipT,1);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.meanHipF = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.hipF,1);
        data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.meanTimeVector = mean(data.(treatments{1,ff}).(whiskDataTypes{1,gg}).Hip.timeVector,1);
    end
end
%% Figures
for ii = 1:length(whiskDataTypes)
        summaryFigure = figure;
        sgtitle(['Volitional whisking - ' whiskDataTypes{1,ii}])
        %% cortical MUA
        ax1 = subplot(6,3,1);
        % C57BL6J
        plot(data.C57BL6J.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.C57BL6J.(whiskDataTypes{1,ii}).meanCortMUA,'color',colors('sapphire'),'LineWidth',1.5);
        hold on
        plot(data.C57BL6J.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.C57BL6J.(whiskDataTypes{1,ii}).meanCortMUA + data.C57BL6J.(whiskDataTypes{1,ii}).adjLH.stdCortMUA,'color',colors('sapphire'),'LineWidth',0.5)
        plot(data.C57BL6J.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.C57BL6J.(whiskDataTypes{1,ii}).meanCortMUA - data.C57BL6J.(whiskDataTypes{1,ii}).adjLH.stdCortMUA,'color',colors('sapphire'),'LineWidth',0.5)
        % Blank-SAP
        plot(data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.meanCortMUA,'color',colors('north texas green'),'LineWidth',1.5);
        plot(data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.meanCortMUA + data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.stdCortMUA,'color',colors('north texas green'),'LineWidth',0.5)
        plot(data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.meanCortMUA - data.Blank_SAP.(whiskDataTypes{1,ii}).adjLH.stdCortMUA,'color',colors('north texas green'),'LineWidth',0.5)
        % SSP-SAP
        plot(data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.meanCortMUA,'color',colors('electric purple'),'LineWidth',1.5);
        plot(data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.meanCortMUA + data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.stdCortMUA,'color',colors('electric purple'),'LineWidth',0.5)
        plot(data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.meanTimeVector,data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.meanCortMUA - data.SSP_SAP.(whiskDataTypes{1,ii}).adjLH.stdCortMUA,'color',colors('electric purple'),'LineWidth',0.5)
        title('LH cortical MUA')
        ylabel('\DeltaP/P (%)')
        xlabel('Peri-whisk time (s)')
        set(gca,'box','off')
        ax1.TickLength = [0.03,0.03];
        
                %% cortical MUA
        ax1 = subplot(6,3,1);
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanCortMUA,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanCortMUA + data.(treatment).ShortWhisks.stdCortMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanCortMUA - data.(treatment).ShortWhisks.stdCortMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3a] Brief whisk cortical MUA')
        ylabel('\DeltaP/P (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax1.TickLength = [0.03,0.03];
       
        %% [1-S3d] brief whisks cortical LFP
        ax4 = subplot(6,3,4);
        imagesc(data.(treatment).ShortWhisks.meanCortT,data.(treatment).ShortWhisks.meanCortF,data.(treatment).ShortWhisks.meanCortS)
        title('[1-S3d] Brief whisk cortical LFP')
        ylabel('Freq (Hz)')
        xlabel('Peri-whisk time (s)')
        c4 = colorbar;
        ylabel(c4,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
        caxis([-25,25])
        set(gca,'Ticklength',[0,0])
        axis square
        axis xy
        set(gca,'box','off')
        ax4.TickLength = [0.03,0.03];
        %% [1-S3e] moderate whisks cortical LFP
        ax5 = subplot(6,3,5);
        imagesc(data.(treatment).IntermediateWhisks.meanCortT,data.(treatment).IntermediateWhisks.meanCortF,data.(treatment).IntermediateWhisks.meanCortS)
        title('[1-S3e] Moderate whisk cortical LFP')
        ylabel('Freq (Hz)')
        xlabel('Peri-whisk time (s)')
        c5 = colorbar;
        ylabel(c5,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
        caxis([-25,25])
        set(gca,'Ticklength',[0,0])
        axis square
        axis xy
        set(gca,'box','off')
        ax5.TickLength = [0.03,0.03];
        %% [1-S3f] extended whisks cortical LFP
        ax6 = subplot(6,3,6);
        imagesc(data.(treatment).LongWhisks.meanCortT,data.(treatment).LongWhisks.meanCortF,data.(treatment).LongWhisks.meanCortS)
        title('[1-S3f] Extended whisk cortical LFP')
        ylabel('Freq (Hz)')
        xlabel('Peri-whisk time (s)')
        c6 = colorbar;
        ylabel(c6,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
        caxis([-25,25])
        set(gca,'Ticklength',[0,0])
        axis square
        axis xy
        set(gca,'box','off')
        ax6.TickLength = [0.03,0.03];
        %% [1-S3g] brief whisks hippocampal MUA
        ax7 = subplot(6,3,7);
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanHipMUA,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanHipMUA + data.(treatment).ShortWhisks.stdHipMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanHipMUA - data.(treatment).ShortWhisks.stdHipMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3g] Brief whisk hippocampal MUA')
        ylabel('\DeltaP/P (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax7.TickLength = [0.03,0.03];
        %% [1-S3h] moderate whisks hippocampal MUA
        ax8 = subplot(6,3,8);
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanHipMUA,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanHipMUA + data.(treatment).IntermediateWhisks.stdHipMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanHipMUA - data.(treatment).IntermediateWhisks.stdHipMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3h] Moderate whisk hippocampal MUA')
        ylabel('\DeltaP/P (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax8.TickLength = [0.03,0.03];
        %% [1-S3i] extended whisks hippocampal MUA
        ax9 = subplot(6,3,9);
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanHipMUA,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanHipMUA + data.(treatment).LongWhisks.stdHipMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanHipMUA - data.(treatment).LongWhisks.stdHipMUA,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3i] Extended whisk hippocampal MUA')
        ylabel('\DeltaP/P (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax9.TickLength = [0.03,0.03];
        %% [1-S3j] brief whisks hippocampal LFP
        ax10 = subplot(6,3,10);
        imagesc(data.(treatment).ShortWhisks.meanHipT,data.(treatment).ShortWhisks.meanHipF,data.(treatment).ShortWhisks.meanHipS)
        title('[1-S3j] Brief whisk hippocampal LFP')
        ylabel('Freq (Hz)')
        xlabel('Peri-whisk time (s)')
        c10 = colorbar;
        ylabel(c10,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
        caxis([-25,25])
        set(gca,'Ticklength',[0,0])
        axis square
        axis xy
        set(gca,'box','off')
        ax10.TickLength = [0.03,0.03];
        %% [1-S3k] moderate whisks hippocampal LFP
        ax11 = subplot(6,3,11);
        imagesc(data.(treatment).IntermediateWhisks.meanHipT,data.(treatment).IntermediateWhisks.meanHipF,data.(treatment).IntermediateWhisks.meanHipS)
        title('[1-S3k] Moderate whisk hippocampal LFP')
        ylabel('Freq (Hz)')
        xlabel('Peri-whisk time (s)')
        c11 = colorbar;
        ylabel(c11,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
        caxis([-25,25])
        set(gca,'Ticklength',[0 0])
        axis square
        axis xy
        set(gca,'box','off')
        ax11.TickLength = [0.03,0.03];
        %% [1-S3l] extended whisks hippocampal LFP
        ax12 = subplot(6,3,12);
        imagesc(data.(treatment).LongWhisks.meanHipT,data.(treatment).LongWhisks.meanHipF,data.(treatment).LongWhisks.meanHipS)
        title('[1-S3l] Extended whisk hippocampal LFP')
        ylabel('Freq (Hz)')
        xlabel('Peri-whisk time (s)')
        c12 = colorbar;
        ylabel(c12,'\DeltaP/P (%)','rotation',-90,'VerticalAlignment','bottom')
        caxis([-25,25])
        set(gca,'Ticklength',[0,0])
        axis square
        axis xy
        set(gca,'box','off')
        ax12.TickLength = [0.03,0.03];
        %% [1-S3m] brief whisks HbT
        ax13 = subplot(6,3,13);
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanHbT,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanHbT + data.(treatment).ShortWhisks.stdHbT,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanHbT - data.(treatment).ShortWhisks.stdHbT,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3m] Brief whisk \Delta[HbT] (\muM)')
        ylabel('\Delta[HbT] (\muM)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax13.TickLength = [0.03,0.03];
        %% [1-S3n] moderate whisks HbT
        ax14 = subplot(6,3,14);
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanHbT,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanHbT + data.(treatment).IntermediateWhisks.stdHbT,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanHbT - data.(treatment).IntermediateWhisks.stdHbT,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3n] Moderate whisk \Delta[HbT] (\muM)')
        ylabel('\Delta[HbT] (\muM)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax14.TickLength = [0.03,0.03];
        %% [1-S3o] extended whisks HbT
        ax15 = subplot(6,3,15);
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanHbT,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanHbT + data.(treatment).LongWhisks.stdHbT,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanHbT - data.(treatment).LongWhisks.stdHbT,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3o] Extended whisk \Delta[HbT] (\muM)')
        ylabel('\Delta[HbT] (\muM)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax15.TickLength = [0.03,0.03];
        %% [1-S3p] brief whisks refl
        ax16 = subplot(6,3,16);
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanCBV,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanCBV + data.(treatment).ShortWhisks.stdCBV,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).ShortWhisks.meanTimeVector,data.(treatment).ShortWhisks.meanCBV - data.(treatment).ShortWhisks.stdCBV,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3p] Brief whisk reflectance')
        ylabel('\DeltaR/R (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax16.TickLength = [0.03,0.03];
        %% [1-S3q] moderate whisks refl
        ax17 = subplot(6,3,17);
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanCBV,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanCBV + data.(treatment).IntermediateWhisks.stdCBV,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).IntermediateWhisks.meanTimeVector,data.(treatment).IntermediateWhisks.meanCBV - data.(treatment).IntermediateWhisks.stdCBV,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3q] Moderate whisk reflectance')
        ylabel('\DeltaR/R (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax17.TickLength = [0.03,0.03];
        %% [1-S3r] extended whisks refl
        ax18 = subplot(6,3,18);
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanCBV,'color',colors('rich black'),'LineWidth',1);
        hold on
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanCBV + data.(treatment).LongWhisks.stdCBV,'color',colors('battleship grey'),'LineWidth',0.5)
        plot(data.(treatment).LongWhisks.meanTimeVector,data.(treatment).LongWhisks.meanCBV - data.(treatment).LongWhisks.stdCBV,'color',colors('battleship grey'),'LineWidth',0.5)
        title('[1-S3r] Extended whisk reflectance')
        ylabel('\DeltaR/R (%)')
        xlabel('Peri-whisk time (s)')
        axis square
        set(gca,'box','off')
        ax18.TickLength = [0.03,0.03];
        %% axes positions
        linkaxes([ax1,ax2,ax3,ax7,ax8,ax9],'xy')
        linkaxes([ax4,ax5,ax6,ax10,ax11,ax12],'xy')
        linkaxes([ax13,ax14,ax15],'xy')
        linkaxes([ax16,ax17,ax18],'xy')
        ax1Pos = get(ax1,'position');
        ax2Pos = get(ax2,'position');
        ax3Pos = get(ax3,'position');
        ax4Pos = get(ax4,'position');
        ax5Pos = get(ax5,'position');
        ax6Pos = get(ax6,'position');
        ax10Pos = get(ax10,'position');
        ax11Pos = get(ax11,'position');
        ax12Pos = get(ax12,'position');
        ax4Pos(3:4) = ax1Pos(3:4);
        ax5Pos(3:4) = ax2Pos(3:4);
        ax6Pos(3:4) = ax3Pos(3:4);
        ax10Pos(3:4) = ax1Pos(3:4);
        ax11Pos(3:4) = ax2Pos(3:4);
        ax12Pos(3:4) = ax3Pos(3:4);
        set(ax4,'position',ax4Pos);
        set(ax5,'position',ax5Pos);
        set(ax6,'position',ax6Pos);
        set(ax10,'position',ax10Pos);
        set(ax11,'position',ax11Pos);
        set(ax12,'position',ax12Pos);
        %% save figure(s)
        if strcmp(saveFigs,'y') == true
            dirpath = [rootFolder delim 'Summary Figures and Structures' delim 'MATLAB Analysis Figures' delim];
            if ~exist(dirpath, 'dir')
                mkdir(dirpath);
            end
            savefig(summaryFigure,[dirpath 'Fig1-S3']);
            set(summaryFigure,'PaperPositionMode','auto');
            print('-painters','-dpdf','-fillpage',[dirpath 'Fig1-S3'])
            %% Text diary
            diaryFile = [dirpath 'Fig1-S3_Statistics.txt'];
            if exist(diaryFile,'file') == 2
                delete(diaryFile)
            end
        end
    end
end

end