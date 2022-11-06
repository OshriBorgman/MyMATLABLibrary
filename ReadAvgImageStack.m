function [rawImgMean] = ReadAvgImageStack(inFold,f,ext)
%READ AND AVERAGE IMAGE STACKS read separate images from a stack and
%average them

% the image stack name
imgStName = dir(fullfile(inFold(f).folder, [inFold(f).name '/*.' ext]));    
% The structure of images in the stack
stackInfo = imfinfo(fullfile(imgStName.folder, imgStName.name));

% Read the images in the stack
rawImgs = zeros(stackInfo(1).Height, stackInfo(1).Width, length(stackInfo)); 
for im = 1:length(stackInfo)
rawImgs(:,:,im) = imread(fullfile(imgStName.folder, imgStName.name), im);
end

% The average image intensity
rawImgMean = mean(rawImgs, 3);
end

