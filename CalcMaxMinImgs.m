function [imgOutput, avgOutput] = CalcMaxMinImgs(imgin, imgRange, ...
    maskImg, brightImg, mdl, Iback, I0, nFilt)
%CALCMAXMINIMGS Calculate maximum and minimum images
%   A more specific function to give the average values of concentration in
%   an image of uniform concentration

imgTrim = imgin(imgRange{1}, imgRange{2});
[imgNorm, CC] = NormIntensImg(imgTrim, maskImg, brightImg);
% Calculate the concentration image
[calcImg] = CalImgCon(imgNorm, maskImg, mdl, 'exp', Iback, I0);
% Filter the images to reduce noise
imgOutput = imfilter(calcImg, ones(nFilt)./(nFilt^2));
% Calculate the maximum concentration
avgOutput = mean(imgOutput(maskImg));

end