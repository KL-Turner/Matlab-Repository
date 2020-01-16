function [] = ExtractCBVData_IOS(ROIs,ROInames,rawDataFileIDs)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Adapted from code written by Dr. Aaron T. Winder: https://github.com/awinde
%________________________________________________________________________________________________________________________
%
%   Purpose: Determine if each desired ROI is drawn, then go through each frame and extract the mean of valid pixels.
%________________________________________________________________________________________________________________________

for a = 1:size(rawDataFileIDs,1)
    rawDataFile = rawDataFileIDs(a,:);
    disp(['Analyzing IOS ROIs from RawData file (' num2str(a) '/' num2str(size(rawDataFileIDs, 1)) ')']); disp(' ')
    [animalID,fileDate,fileID] = GetFileInfo_IOS(rawDataFile);
    strDay = ConvertDate_IOS(fileDate);
    load(rawDataFile)
    for b = 1:length(ROInames)
        ROIshortName = ROInames{1,b}; 
        ROIname = [ROInames{1,b} '_' strDay];
        if ~isfield(RawData.data,'CBV')
            RawData.data.CBV = [];
        end
        % check if ROI exists
        if ~isfield(RawData.data.CBV,ROIname)
            [frames] = ReadDalsaBinary_IOS(animalID,[fileID '_WindowCam.bin']);
            disp(['Extracting ' ROIname ' ROI CBV data from ' rawDataFile '...']); disp(' ')
            % draw circular ROIs based on XCorr for LH/RH/Barrels, then free-hand for cement ROIs
            if strcmp(ROIshortName,'LH') == true || strcmp(ROIshortName,'RH') == true
                circROI = drawcircle('Center',ROIs.(ROIname).circPosition,'Radius',ROIs.(ROIname).circRadius);
                mask = createMask(circROI,frames{1});
            else
                mask = roipoly(frames{1},ROIs.(ROIname).xi,ROIs.(ROIname).yi);
            end
            meanIntensity = BinToIntensity_IOS(mask,frames);
            RawData.data.CBV.(ROIname) = meanIntensity;
            save(rawDataFile,'RawData')
        else
            disp([ROIname ' ROI CBV data from ' rawDataFile ' already extracted. Continuing...']); disp(' ')
        end
    end
end

end

