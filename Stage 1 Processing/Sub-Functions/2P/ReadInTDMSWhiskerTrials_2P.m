function [TDMSFile] = ReadInTDMSWhiskerTrials_2P(fileName)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Pull the data and notes from the LabVIEW '.tdms' files into a Matlab structure.
%________________________________________________________________________________________________________________________
%
%   Inputs: File name ending in '.tdms' that contains the LabVIEW aquired analog data and notes from the session.
%
%   Outputs: Structure containing the data (arranged into rows with corresponding labels in a different field)
%            and various descriptive variables/strings of the session notes.
%
%   Last Revised: March 21st, 2019
%________________________________________________________________________________________________________________________

%% Convert the .tdms file into something that Matlab understands
[tempStruct, ~] = ConvertTDMS_SlowOscReview2019(0, fileName);

% Extract Whisker Camera info and transfer from tempStruct
TDMSFile.experimenter = tempStruct.Data.Root.Experimenter;
TDMSFile.animalID = tempStruct.Data.Root.Animal_ID;
TDMSFile.imagedHemisphere = tempStruct.Data.Root.Hemisphere;
TDMSFile.isofluraneTime_Military = tempStruct.Data.Root.Isoflurane_time;
TDMSFile.sessionID = tempStruct.Data.Root.Session_ID;
TDMSFile.amplifierGain = tempStruct.Data.Root.Amplifier_Gain;
TDMSFile.whiskerCamSamplingRate_Hz = tempStruct.Data.Root.WhiskerCam_Fs;
TDMSFile.analogSamplingRate_Hz = tempStruct.Data.Root.Analog_Fs;
TDMSFile.trialDuration_Seconds = tempStruct.Data.Root.TrialDuration_sec;
TDMSFile.whiskerCamPixelHeight = tempStruct.Data.Root.Whisker_Cam_Height_pix;
TDMSFile.whiskerCamPixelWidth = tempStruct.Data.Root.Whisker_Cam_Width_pix;
TDMSFile.numberDroppedWhiskerCamFrames = tempStruct.Data.Root.WhiskerCam_NumberDropped;
TDMSFile.droppedWhiskerCamFrameIndex = tempStruct.Data.Root.WhiskerCam_DroppedFrameIndex;
       
% Pre-allocate - Data is contained in .vals folder in rows with corresponding labels in .names
TDMSFile.data.vals = NaN*ones(length(tempStruct.Data.MeasuredData), length(tempStruct.Data.MeasuredData(1).Data));
TDMSFile.data.names = cell(length(tempStruct.Data.MeasuredData), 1) ;

% Pull data from tempStruct and allocate it in the proper areas 
for a = 1:length(tempStruct.Data.MeasuredData)
    TDMSFile.data.vals(a,:) = tempStruct.Data.MeasuredData(a).Data;
    TDMSFile.data.names{a} = strrep(tempStruct.Data.MeasuredData(a).Name, 'Analog_Data', '');
end

end

