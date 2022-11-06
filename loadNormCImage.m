function [imgNorm, imgRaw] = loadNormCImage(rawImgsFolder, rawImgsFile, imgRange, ...
    grainMask, brightImg)
%LOADNORMCIMAGE Load and normalize concentration images
%   Load raw images, and normalize them to correct illumination etc.

% INPUT
% rawImgsFolder: The folder of raw images
% rawImgsFile: the file name of the image
% imgRange: the pixel range to crop the image if necessary
% grainMask: the grain mask
% brightImg: the bright image for illumination correction

% Load the image
imgRaw = fliplr(double(imread(fullfile(rawImgsFolder, rawImgsFile), "png")))./(2^16-1);
% % Limit the range
% imgRaw = imgRaw(imgRange{1}, imgRange{2});

% Normalize the image
[imgNorm, CC] = NormIntensImg(imgRaw(imgRange{1}, imgRange{2}), grainMask, brightImg);

% Remove the grains from the concentration image
imgNorm(~grainMask) = 0;

end