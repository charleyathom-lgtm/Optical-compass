% Select parent folder containing multiple subfolders
%this program selects a folder containing all the mesurments themselves
%containing sevral batches, it allows the user to plot the median angle of
%each measurment with respect to the chronological order of each measurement
parentFolder = uigetdir;
if parentFolder == 0
    disp('No parent folder selected. Exiting.');
    return;
end

% Get a list of all subfolders
folderInfo = dir(parentFolder);
subFolders = folderInfo([folderInfo.isdir] & ~ismember({folderInfo.name}, {'.', '..'}));

% Initialize results
folderNames = {};
medianAngles = [];

% Regex to match filenames with batch and angle (including negative angles)
pattern = 'matrices_batch_(\d+)_Image_az_(-?\d+\.\d+)';

for i = 1:length(subFolders)
    folderPath = fullfile(parentFolder, subFolders(i).name);
    imageFiles = [dir(fullfile(folderPath, '*.tif')); dir(fullfile(folderPath, '*.tiff'))];
    
    if isempty(imageFiles)
        fprintf('No TIFF images found in folder: %s\n', subFolders(i).name);
        continue;
    end

    angles = [];
    
    for j = 1:length(imageFiles)
        filename = imageFiles(j).name;
        tokens = regexp(filename, pattern, 'tokens');
        
        if ~isempty(tokens)
            angle = str2double(tokens{1}{2});
            angles = [angles; angle];
        end
    end

    if isempty(angles)
        fprintf('No valid angles found in folder: %s\n', subFolders(i).name);
        continue;
    end

    % Apply median filtering and store results
    folderNames{end+1} = subFolders(i).name;
    medianAngles(end+1) = median(angles);
end

% Plot results
figure;
plot(1:length(medianAngles), medianAngles, '-o', 'LineWidth', 2);
xticks(1:length(folderNames));
xticklabels(folderNames);
xtickangle(45);
xlabel('Folder (Batch Group)');
ylabel('Median Angle (degrees)');
title('Median Angles from Multiple Folders');
grid on;

% Print results
disp('Median angle per folder:');
for i = 1:length(folderNames)
    fprintf('%s: %.2f degrees\n', folderNames{i}, medianAngles(i));
end

