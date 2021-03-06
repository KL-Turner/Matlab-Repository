function [ROIs] = CheckROIDates_IOS(animalID,ROIs,ROInames,imagingType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Create/Update ROIs.mat structure to verify all ROIs are drawn
%________________________________________________________________________________________________________________________

% Character list of all WindowCam files
windowCamFilesDir = dir('*_WindowCam.bin');
windowCamDataFiles = {windowCamFilesDir.name}';
windowCamDataFileIDs = char(windowCamDataFiles);
% establish the number of unique days based on file IDs
[~,fileDates,~] = GetFileInfo_IOS(windowCamDataFileIDs);
[uniqueDays,~,DayID] = GetUniqueDays_IOS(fileDates);
firstsFileOfDay = cell(1,length(uniqueDays));
for a = 1:length(uniqueDays)
    FileInd = DayID == a;
    dayFilenames = windowCamDataFileIDs(FileInd,:);
    firstsFileOfDay(a) = {dayFilenames(1,:)};
end
% load existing ROI structure if it exists
ROIFileDir = dir('*_ROIs.mat');
ROIFileName = {ROIFileDir.name}';
ROIFileID = char(ROIFileName);
if exist(ROIFileID)
    load(ROIFileID);
else
    ROIs = [];
end
% Create the desired window ROI for each day if it doesn't yet exist
for b = 1:length(firstsFileOfDay)
    fileID = firstsFileOfDay{1,b};
    strDay = ConvertDate_IOS(fileID);
    for c = 1:length(ROInames)
        ROIname = [ROInames{1,c} '_' strDay];
        if ~isfield(ROIs,(ROIname))
            if strcmp(ROInames{1,c},'LH') == true || strcmp(ROInames{1,c},'RH') == true
                [ROIs] = CalculateROICorrelationMatrix_IOS(animalID,strDay,fileID,ROIs,imagingType);
            else
                [frames] = ReadDalsaBinary_IOS(animalID,fileID);
                [ROIs] = CreateBilateralROIs_IOS(frames{1},ROIname,animalID,ROIs);
            end
            save([animalID '_ROIs.mat'],'ROIs');
        end
    end
end

end
