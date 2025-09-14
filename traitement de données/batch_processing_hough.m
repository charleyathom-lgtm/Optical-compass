%this srcypt uses hough transphorm to process large amounts of aopl
%matrixes and returns pictures with the azimuth value only

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

        % Process the matrices (example: display size)
        

        AoP = aopl;
%AoP =cell2mat(struct2cell(AoP)); % not needed as aopl is already a matrix

[nb_row,nb_col] = size(AoP);
x_center = nb_col/2;
y_center = nb_row/2;

%Apply circular mask to AoP
I = mat2gray(AoP*180/pi,[-90,90]);
%Epsilon in degree converted to rad
Epsilon = 1*pi/180;
%Mask to select AoP values around +90° ou -90°
Mask = (pi/2-Epsilon < abs(AoP)) & (abs(AoP) < pi/2+Epsilon);
I(~Mask)=false;
imshow(I)

%I = flipud(I);
se = strel('line',3,90);
cleanI = imdilate(I,se);
%cleanI = flipud(cleanI);
imshow(cleanI);

%added by charley

edges = edge(cleanI, 'canny', [0.1 0.2]);  % Adjust thresholds
imshow(edges);

[H,theta,rho] = hough(edges); %used to have cleanI as argument
peaks  = houghpeaks(H,10);
lines = houghlines(I,theta,rho,peaks);

hold on;
x1 = lines(2).point1(1);
y1 = lines(2).point1(2);
x2 = lines(2).point2(1);
y2 = lines(2).point2(2);
plot([x1 x2],[y1 y2],'Color','g','LineWidth', 2)

%az_hat = (pi/2+lines(1).theta*pi/180)*180/pi
az_hat = lines(1).theta

%line_ploting(lines,cleanI)




% Generate an example image (replace with your image)
img = cleanI; % Example grayscale image

folderPath="C:\Users\charl\Desktop\Stage 2025\work\Optical_Compass-main_original\Optical_Compass-main_1\Optical_Compass-main\mass image processing\outdoor 24.04\batch4"; %change batch name every time

if ~exist(folderPath, 'dir')
    mkdir(folderPath);
    disp(['Folder created: ', folderPath]);
end
az=az_hat;
batchName =  batch_name;  % Example batch name, modify as needed
filename = sprintf("%s_Image_az_%.2f.tiff", batchName,az);  % Change extension as needed (.png, .jpg, .tif)

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

