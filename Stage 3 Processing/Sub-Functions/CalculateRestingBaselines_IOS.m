function [RestingBaselines] = CalculateRestingBaselines_IOS(animal, targetMinutes, RestData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% Ph.D. Candidate, Department of Bioengineering
% The Pennsylvania State University
%________________________________________________________________________________________________________________________
%
%   Purpose: This function finds the resting baseline for all fields of the RestData.mat structure, for each unique day
%________________________________________________________________________________________________________________________
%
%   Inputs: animal name (str) for saving purposes, targetMinutes (such as 30, 60, etc) which the code will interpret as 
%           the number of minutes/files at the beginning of each unique imaging day to use for baseline calculation. 
%           RestData.mat, which should have field names such as CBV, Delta Power, Gamma Power, etc. with ALL resting events
%
%   Outputs: SleepRestEventData.mat struct
%
%   Last Revision: October 4th, 2018
%________________________________________________________________________________________________________________________

% The RestData.mat struct has all resting events, regardless of duration. We want to set the threshold for rest as anything
% that is greater than 10 seconds.
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {10};

puffCriteria.Fieldname = {'puffDistances'};
puffCriteria.Comparison = {'gt'};
puffCriteria.Value = {5};

% Find the fieldnames of RestData and loop through each field. Each fieldname should be a different dataType of interest.
% These will typically be CBV, Delta, Theta, Gamma, and MUA
dataTypes = fieldnames(RestData);
for a = 1:length(dataTypes)
    dataType = char(dataTypes(a));   % Load each loop iteration's fieldname as a character string
    subDataTypes = fieldnames(RestData.(dataType));   % Find the hemisphere dataTypes. These are typically LH, RH     
    
    % Loop through each hemisphere dataType (LH, RH) because they are subfields and will have unique baselines
    for b = 1:length(subDataTypes)
        subDataType = char(subDataTypes(b));   % Load each loop iteration's hemisphere fieldname as a character string
        
        % Use the RestCriteria we specified earlier to find all resting events that are greater than the criteria
        [restLogical] = FilterEvents_IOS(RestData.(dataType).(subDataType), RestCriteria);   % Output is a logical
        [puffLogical] = FilterEvents_IOS(RestData.(dataType).(subDataType), puffCriteria);   % Output is a logical   
        combRestLogical = logical(restLogical.*puffLogical);
        allRestFiles = RestData.(dataType).(subDataType).fileIDs(combRestLogical, :);   % Overall logical for all resting file names that meet criteria
        allRestDurations = RestData.(dataType).(subDataType).durations(combRestLogical, :);
        allRestEventTimes = RestData.(dataType).(subDataType).eventTimes(combRestLogical, :);
        restingData = RestData.(dataType).(subDataType).data(combRestLogical, :);   % Pull out data from all those resting files that meet criteria
        
        uniqueDays = GetUniqueDays_IOS(RestData.(dataType).(subDataType).fileIDs);   % Find the unique days of imaging
        uniqueFiles = unique(RestData.(dataType).(subDataType).fileIDs);   % Find the unique files from the filelist. This removes duplicates
                                                                           % since most files have more than one resting event
        numberOfFiles = length(unique(RestData.(dataType).(subDataType).fileIDs));   % Find the number of unique files 
        fileTarget = targetMinutes / 5;   % Divide that number of unique files by 5 (minutes) to get the number of files that
                                          % corresponds to the desired targetMinutes
        
        % Loop through each unique day in order to create a logical to filter the file list so that it only includes the first 
        % x number of files that fall within the targetMinutes requirement
        for c = 1:length(uniqueDays)
            day = uniqueDays(c);
            f = 1;
            for nOF = 1:numberOfFiles
                file = uniqueFiles(nOF);
                fileID = file{1}(1:6);
                if strcmp(day, fileID) && f <= fileTarget
                    filtLogical{c, 1}(nOF, 1) = 1;
                    f = f + 1;
                else
                    filtLogical{c, 1}(nOF, 1) = 0;
                end
            end
        end
        % Combine the 3 logicals so that it reflects the first "x" number of files from each day
        finalLogical = any(sum(cell2mat(filtLogical'), 2), 2);
        
        % Now that the appropriate files from each day are identified, loop through each file name with respect to the original
        % list of ALL resting files, only keeping the ones that fall within the first targetMinutes of each day.
        filtRestFiles = uniqueFiles(finalLogical, :);
        for d = 1:length(allRestFiles)
            logic = strcmp(allRestFiles{d}, filtRestFiles);
            logicSum = sum(logic);
            if logicSum == 1
                fileFilter(d, 1) = 1;
            else
                fileFilter(d, 1) = 0;
            end
        end

        finalFileFilter = logical(fileFilter);
        finalFileIDs = allRestFiles(finalFileFilter, :);
        finalFileDurations = allRestDurations(finalFileFilter, :);
        finalFileEventTimes = allRestEventTimes(finalFileFilter, :);
        finalRestData = restingData(finalFileFilter, :);
        
        % Loop through each unique day and pull out the data that corresponds to the resting files
        for e = 1:length(uniqueDays)
            z = 1;
            for f = 1:length(finalFileIDs)
                fileID = finalFileIDs{f, 1}(1:6);
                date{e, 1} = ConvertDate_IOS(uniqueDays{e, 1});
                if strcmp(fileID, uniqueDays{e, 1}) == 1     
                    tempData.(date{e, 1}){z, 1} = finalRestData{f, 1};
                    z = z + 1;
                end
            end
        end
        
        % find the means of each unique day
        for g = 1:size(date, 1)
            tempData_means{g, 1} = cellfun(@(x) mean(x), tempData.(date{g, 1}));    % LH date-specific means
        end
        
        % Save the means into the Baseline struct under the current loop iteration with the associated dates
        for h = 1:length(uniqueDays)
            RestingBaselines.(dataType).(subDataType).(date{h, 1}) = mean(tempData_means{h, 1});    % LH date-specific means
        end
        
    end
end

RestingBaselines.baselineFileInfo.fileIDs = finalFileIDs;
RestingBaselines.baselineFileInfo.eventTimes = finalFileEventTimes;
RestingBaselines.baselineFileInfo.durations = finalFileDurations;
RestingBaselines.targetMinutes = targetMinutes;
save([animal '_RestingBaselines.mat'], 'RestingBaselines');

end
