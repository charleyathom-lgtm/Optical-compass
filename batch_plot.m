%this program selects a folder with processed images and plots the azimuth
%angle with respect to the bath number
% Select folder
folder = uigetdir;
if folder == 0
    disp('No folder selected. Exiting.');
    return;
end

% Get all image files in the folder
imageFiles = [dir(fullfile(folder, '*.tif')); dir(fullfile(folder, '*.tiff'))];

if isempty(imageFiles)
    disp('No TIFF images found in the selected folder.');
    return;
end

% Initialize arrays
angles = [];
batchNumbers = [];

% Regular expression to extract batch number and angle
pattern = 'matrices_batch_(\d+)_Image_az_(-?\d+\.\d+)';

for i = 1:length(imageFiles)
    filename = imageFiles(i).name;
    tokens = regexp(filename, pattern, 'tokens');
    
    if ~isempty(tokens)
        batch = str2double(tokens{1}{1});
        angle = str2double(tokens{1}{2});
        
        batchNumbers = [batchNumbers; batch];
        angles = [angles; angle];
    end
end

% Sort data by batch number
[batchNumbers, sortIdx] = sort(batchNumbers);
angles = angles(sortIdx);

% Plot the angles over batch numbers
figure;
plot(batchNumbers, angles, '-o', 'LineWidth', 2);
xlabel('Batch Number');
ylabel('Angle (degrees)');
title('Angle vs. Batch Number');
grid on;

% Display results
disp('Plot generated successfully.');
