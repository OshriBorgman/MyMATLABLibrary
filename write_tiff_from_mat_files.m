% % WRITE TIFF IMAGES FROM .MAT FILES
% This script opens .mat files containing images and saves them as separate
% tiff images

%% Select folders and set parameters

clear
addpath(genpath(pwd))
% Open a file to write the processing details
analyzImgsFolder = uigetdir('I:\Rennes projects\Unsaturated transport\Processed images\', 'Choose output images folder');
fileID = fopen(fullfile(analyzImgsFolder,'processing_pars.txt'),'a+');
fprintf(fileID,'Image processing on %s\n------------------\n',...
    date);
fprintf(fileID,'Saving images in %s\n------------------\n',...
    analyzImgsFolder);
fclose(fileID);

imgRange = {':', ':'};
% imgRange = {51:1950, 101:2000};

%% Load the grain mask and reference images

% % Load the grain mask
[grainMaskFileName, grainMaskFilePath] = uigetfile('I:\Rennes projects\Unsaturated transport\Experiment images\*.mat', ...
    'Choose grain mask image');

grainMaskImg0 = load(fullfile(grainMaskFilePath, grainMaskFileName));
grainMaskImg = fliplr(grainMaskImg0.grainMask);

fprintf('Reading grain mask %s\n',...
    fullfile(grainMaskFilePath, grainMaskFileName));

% Plot the images
figure;
imagesc(grainMaskImg)
axis equal tight
% title(refImgsFileName, 'Interpreter', "none")
% Create the reduced grain mask

grainMaskTrim = logical(grainMaskImg(imgRange{1}, imgRange{2}));
grainMaskDilInv = imdilate(~grainMaskTrim, strel('disk', 4, 0));
grainMaskDil = ~grainMaskDilInv;

% Load reference images
[refImgsFileName, refImgsFilePath] = uigetfile(fullfile(grainMaskFilePath, '*.mat'), 'Choose reference images file');
% S = load(fullfile(refImgsFilePath, refImgsFileName));

W = whos('-file',fullfile(refImgsFilePath, refImgsFileName));
W.name

% Choose the reference bright image
brightImgVarName = input('Select bright image: ');
brightImgVar0 = load(fullfile(refImgsFilePath, refImgsFileName), brightImgVarName);
fprintf('Reading bright image %s\n', brightImgVarName);

% Convert the variable to an array and average from several images
brightImgVar1 = struct2cell(brightImgVar0);
brightImgVar2 = brightImgVar1{:};
brightImgVar3 = mean(brightImgVar2, 4);
brightImg0 = fliplr(brightImgVar3)./(2^16-1);

clear brightImgVar0 brightImgVar1 brightImgVar2 brightImgVar3

% Set the image range
brightImg = brightImg0(imgRange{1}, imgRange{2});

% Choose the maximum concentration image
maxImgVarName = input('Select max image: ');
maxImgVar0 = load(fullfile(refImgsFilePath, refImgsFileName), maxImgVarName);
fprintf('Reading maximum image %s\n', maxImgVarName);

% Convert the variable to an array and average from several images
maxImgVar1 = struct2cell(maxImgVar0);
maxImgVar2 = maxImgVar1{:};
maxImgVar3 = mean(maxImgVar2, 4);
maxImg0 = fliplr(maxImgVar3)./(2^16-1);

clear maxImgVar0 maxImgVar1 maxImgVar2 maxImgVar3

% Set the image range
maxImg = maxImg0(imgRange{1}, imgRange{2});

% Normalize the image
[imgMaxNorm, CC] = NormIntensImg(maxImg, grainMaskTrim, brightImg);

% Filter the image
imgMaxFilt = imfilter(imgMaxNorm, ones(5)./(5^2));

% Open a file to write the processing details
fileID = fopen(fullfile(analyzImgsFolder,'processing_pars.txt'),'a+');
fprintf(fileID,'Reading grain mask %s\n------------------\n',...
    fullfile(grainMaskFilePath, grainMaskFileName));
fprintf(fileID,'Reading bright image %s\n------------------\n',...
    fullfile(grainMaskFilePath, brightImgVarName));
fprintf(fileID,'Reading maximum image %s\n------------------\n',...
    fullfile(grainMaskFilePath, maxImgVarName));
fclose(fileID);

%% Analyze multiple .mat files

% Select generic file name containing processed data
[analyzeDataFileName, analyzeDataFolder] = uigetfile('I:\Rennes projects\Unsaturated transport\Experiment images\','Select the raw data file');
fprintf('------------------\nreading files from %s\n------------------\n',...
    analyzeDataFolder);

% Find all files
allFiles = dir(fullfile(analyzeDataFolder,[analyzeDataFileName(1:end-20) '*.mat']));

for n = 15:length(allFiles)
    % Load the images file
    load(fullfile(analyzeDataFolder, allFiles(n).name))
    fprintf('------------------\nanalyzing file %s\n------------------\n',...
    allFiles(n).name(1:end-4));
    %     Reduce excess dimensions
    C = squeeze(frames);
    clear frames
    %     Create a folder to save images if one doesn't exist
    if ~exist(fullfile(analyzImgsFolder, allFiles(n).name(1:end-4)), 'dir')
        mkdir(fullfile(analyzImgsFolder, allFiles(n).name(1:end-4)))
    end
    
    %     Loop over the images
    for i = 1:size(C, 3)
        
        fprintf('Analyzing image %d of %d\n', i, size(C, 3))
        
        % Load the image
        imgRaw = fliplr(double(C(:,:,i)))./(2^16-1);
        % Limit the range
        imgRaw = imgRaw(imgRange{1}, imgRange{2});
        
        % Normalize the image
        [imgNorm, ~] = NormIntensImg(imgRaw, grainMaskTrim, brightImg);
        clear imgRaw
        
        %     Filter the image
        imgNormFilt = imfilter(imgNorm, ones(5)./(5^2));
        clear imgNorm
        
        %     Divide by the maximum image
        imgNormFilt = imgNormFilt./imgMaxFilt;
        
        % Remove the grains from the concentration image
        imgNormFilt(~grainMaskTrim) = 0;
        
        %         Convert back to 16-bit
        imgNormFilt16 = uint16(imgNormFilt.*(2^16-1));
        %         PlotFieldImage(imgNormFilt16);  caxis([0 2^16])
        %         Plot an invisible image
        figure('Visible', 'off')
        f = imagesc(imgNormFilt16); axis equal tight
        %       Define the file name
        fnamesave = fullfile(analyzImgsFolder, allFiles(n).name(1:end-4), ...
            sprintf('norm_img_%04d.tiff', i));
        %         Obtain the actual data of the image and write to file
        imwrite(f.CData, fnamesave)
        
    end
    
    clear C
end