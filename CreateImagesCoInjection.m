% Select folder for raw images
[rawImgsFolder] = uigetdir('../','Select the folder of raw images');
fprintf('------------------\nReading images from %s\n------------------\n',...
    rawImgsFolder);
% Select folder for analyzed images
[analyzImgsFolder] = uigetdir('../','Select the folder of analyzed images');
fprintf('------------------\nSaving images in %s\n------------------\n',...
    analyzImgsFolder);

% Get the image names
rawImgFiles = dir([rawImgsFolder '\*.png']);

for i = 130:length(rawImgFiles)

% Load the image
imgRaw = fliplr(double(imread(fullfile(rawImgsFolder, rawImgFiles(i).name), "png")))./(2^16-1);
% Limit the range
imgRaw = imgRaw(imgRange{1}, imgRange{2});

% Homogenize the image
imgNorm = imgRaw./avgCorrectFacs.*grainMask(imgRange{1}, imgRange{2});

clear imgRaw

% Plot the grains in high contrast
imgNorm(~grainMask(imgRange{1}, imgRange{2})) = prctile(imgNorm(:),50);
% % Threshold the image to obtain the shape of the liquid phase
% imgNormThresh1 = graythresh(imgNorm);
% Threshold the image to obtain the shape of the liquid phase, for a pulse
% injection use multithresh
imgNormThresh1 = multithresh(imgNorm, 20);
imgNormAdaptThresh2 = imbinarize(imgNorm, imgNormThresh1(1));
imgNormAdaptThresh3 = ~imgNormAdaptThresh2;
% Remove the grains
imgNormAdaptThresh3(~grainMask(imgRange{1}, imgRange{2})) = 1;

% % Convert to RGB image, use an 8-bit encoding to match the colormap
% imgNormRGB = ind2rgb(uint8(imgNorm./(2^16-1).*(2^8-1)), bl_to_rd_diver_cmap);

% Display
fig = figure(11);
clf
% fig.Visible = "on"
ax = gca;
% The grain mask
im = ind2rgb(uint8((double(~grainMask(imgRange{1}, imgRange{2}))*0.6)*(2^8-1)), gray);
imAlphaData = grainMask(imgRange{1}, imgRange{2})==0;
% Create an image and its corresponding transparency data
bg = zeros(size(imgNorm, 1), size(imgNorm, 2), 3);
bg = bg + ind2rgb(uint8(imgNorm.*~imgNormAdaptThresh3.*(2^8-1)), bl_to_rd_diver_cmap);
% % imAir = ind2rgb(uint8(double(~imgNormAdaptThresh3)*(2^8-1)), gray);
% % % Overlay the air pattern on the previous images
% % imOut2 = image(imAir);
% % set(imOut2,'AlphaData',~imAlphaData);
ibg2 = image(bg);
% axis off
hold on
% Overlay the grain image, and set the transparency previously calculated
imOut = image(im);
set(imOut,'AlphaData',imAlphaData);
axis equal tight
axis off
fig.Units = 'normalized';
fig.Position = [0.1 0.1 0.6 0.6];

% Save image
frame = getframe(ax);
imwrite(frame.cdata, bl_to_rd_diver_cmap, fullfile(analyzImgsFolder,...
    rawImgFiles(i).name), 'png')

end