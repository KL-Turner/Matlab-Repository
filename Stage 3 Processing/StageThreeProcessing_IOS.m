%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner 
% Ph.D. Candidate, Department of Bioengineering 
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: 1) Categorize data using previously processed ProcData data structures, add 'flags'  
%            2) Create RestData structure that contains periods of rest.
%            3) Create EventData structure that contains periods after stimuli and whisks.
%            4) Uses periods when animal is not being stimulated or moving to establish a 
%               baseline for a given session of imaging.
%            5) Normalizes the different data structures.
%________________________________________________________________________________________________________________________
%
%   Inputs: 1) Select all _ProcData files from all days. Follow the command window prompts.
%           2) Select one single _RawData file for the animal information. The ProcData files are
%              already in the list and will be used to run the function.
%           3) No inputs. ProcData files already loaded.
%           4) No inputs. RestData.mat is already loaded.
%           5) No inputs. RestData.mat and EventData.mat are already loaded.
%
%   Outputs: 1) Additions to the ProcData structure including flags and scores.
%            2) A RestData.mat structure with periods of rest.
%            3) A EventData.mat structure with event-related information.
%            4) Baselines.mat containing the baselines for individual resting periods.
%            5) Creates NormData in the rest/event structures.
%
%   Last Revised: October 5th, 2018
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Load the script's necessary variables and data structures.
% Clear the workspace variables and command window.
clc;
clear;
disp('Analyzing Block [0] Preparing the workspace and loading variables.'); disp(' ')

% Character list of all ProcData files
procDataFileStruct = dir('*_ProcData.mat');
procDataFiles = {procDataFileStruct.name}';
procDataFiles = char(procDataFiles);
[animalID, ~, ~] = GetFileInfo_IOS(procDataFiles(1,:));

targetMinutes = input('Input the target minutes for the resting baseline: '); disp(' ')
dataTypes = {'CBV', 'cortical_LH', 'cortical_RH', 'hippocampus'};

%% BLOCK PURPOSE: [1] Categorize data 
disp('Analyzing Block [1] Categorizing data.'); disp(' ')
for a = 1:size(procDataFiles, 1)
    procDataFile = procDataFiles(a, :);
    disp(['Analyzing file ' num2str(a) ' of ' num2str(size(procDataFiles, 1)) '...']); disp(' ')
    CategorizeData_IOS(procDataFile)
end

%% BLOCK PURPOSE: [2] Create RestData data structure
disp('Analyzing Block [2] Create RestData struct for CBV and neural data.'); disp(' ')
[RestData] = ExtractRestingData_IOS(procDataFiles, dataTypes);
    
%% BLOCK PURPOSE: [3] Create EventData data structure
disp('Analyzing Block [3] Create EventData struct for CBV and neural data.'); disp(' ')
[EventData] = ExtractEventTriggeredData_IOS(procDataFiles, dataTypes);

%% BLOCK PURPOSE: [4] Create Baselines data structure
disp('Analyzing Block [4] Create Baselines struct for CBV and neural data.'); disp(' ')
disp(['Calculating the resting baselines for the first ' num2str(targetMinutes) ' minutes of each unique day...']); disp(' ')
[RestingBaselines] = CalculateRestingBaselines_IOS(animalID, targetMinutes, RestData);

%% BLOCK PURPOSE: [5] Normalize RestData and behavioral data
disp('Analyzing Block [5] Normalize EventData struct using Baselines for CBV and neural data.'); disp(' ')
[RestData] = NormBehavioralDataStruct_IOS(RestData, RestingBaselines);
save([animalID '_RestData.mat'], 'RestData')

[EventData] = NormBehavioralDataStruct_IOS(EventData, RestingBaselines);
save([animalID '_EventData.mat'], 'EventData')

%% BLOCK PURPOSE: [6]

%% BLOCK PURPOSE: [7]
%% BLOCK PURPOSE [5] Analyze the spectrogram for each session.
disp('Analyzing Block [5] Analyzing the spectrogram for each file and normalizing by the resting baseline.'); disp(' ')
CreateTrialSpectrograms_2P(mergedDataFiles);

% Find spectrogram baselines for each day
specDirectory = dir('*_SpecData.mat');
specDataFiles = {specDirectory.name}';
specDataFiles = char(specDataFiles);
[RestingBaselines] = CalculateSpectrogramBaselines_2P(animalID, trialDuration_Sec, specDataFiles, RestingBaselines);

% Normalize spectrogram by baseline
NormalizeSpectrograms_2P(specDataFiles, RestingBaselines);

%% BLOCK PURPOSE [6]
GenerateSingleFigures_2P(mergedDataFiles, RestingBaselines)




disp('Stage Three Processing - Complete.'); disp(' ')
