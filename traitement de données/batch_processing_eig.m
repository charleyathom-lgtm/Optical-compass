%this srcypt uses the eighen value method transphorm to process large amounts of aopl
%matrixes and returns pictures with the azimuth value and elevation

% Select the folder containing .mat files
folder_path = uigetdir('', 'Select Folder Containing Matrices');

% Check if the user canceled selection
if folder_path == 0
    disp('No folder selected.');
    return;
end

% Get list of all .mat files in the folder
mat_files = dir(fullfile(folder_path, '*.mat'));

% Check if there are .mat files
if isempty(mat_files)
    disp('No .mat files found in the selected folder.');
    return;
end

% Loop through each .mat file
for i = 1:length(mat_files)
    % Get full file path
    file_path = fullfile(folder_path, mat_files(i).name);

    % Extract the file name without extension
    [~, batch_name, ~] = fileparts(mat_files(i).name);
    
    % Display extracted batch name
    fprintf('Processing file: %s (Batch Name: %s)\n', mat_files(i).name, batch_name);
    
    
    % Load .mat file
    data = load(file_path);
    
    % Check if required variables exist
    if isfield(data, 'azimut') && isfield(data, 'elevation') && isfield(data, 'aopl')
        azimut = data.azimut;
        elevation = data.elevation;
        aopl = data.aopl;

        % Process the matrices (stephan's program)


        



        % for sun_Estimator_az_eig program

[Azimuth_sun_hat,Elevation_sun_hat,cleanI]= Sun_Estimator_az_eig2(azimut, elevation, aopl);
eph = ['Sun Elevation = ', num2str(Elevation_sun_hat), ', Sun Azimuth = ', num2str(Azimuth_sun_hat)];
a_deg=Azimuth_sun_hat*(360/(2*pi));
e_deg=Elevation_sun_hat*(360/(2*pi));
deg = ['Sun Elevation in degrees = ', num2str(e_deg), ', Sun Azimuth in degrees = ', num2str(a_deg)];
disp(eph)
disp(deg)





% Generate an example image (replace with your image)
img = cleanI; % Example grayscale image

folderPath="C:\Users\charl\Desktop\Stage 2025\work\Optical_Compass-main_original\Optical_Compass-main_1\Optical_Compass-main\mass image processing\minisun_2\test1"; %change batch name every time

if ~exist(folderPath, 'dir')
    mkdir(folderPath);
    disp(['Folder created: ', folderPath]);
end
az=a_deg;
el=e_deg;
batchName =  batch_name;  % Example batch name, modify as needed
filename = sprintf("%s_Image_az_%.4f_E_%.4f.tiff", batchName,az,el);  % Change extension as needed (.png, .jpg, .tif)

% Full file path
fullFilePath = fullfile(folderPath, filename);
    % Save the image
    imwrite(img, fullFilePath);
    
    disp(['Image saved successfully as: ', fullFilePath]);




    else
        fprintf('Skipping %s: Required variables not found.\n', mat_files(i).name);
    end
end

disp('Processing complete.');