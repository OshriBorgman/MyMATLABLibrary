function [C, G, gradBinCount, gradPDF, gradPDFEdges, saveMeanGrad, saveMaxGrad] = ...
    SaveNormalizeImageConcentrationGradientB...
    (rawImgPath, rawImgFiles, refImg, cropMiddle, imgRange, ...
    fmg, grainMask, unsatMaskImg, frIdx, pixLen, concImgsFolder, gradImgsFolder, ...
    gradBinCount, gradPDF, gradPDFEdges, saveMeanGrad, saveMaxGrad, mixZoneMaxC, ...
    mixZoneMinC)

% SAVE NORMALIZED IMAGE CONCENTRATION AND GRADIENTS
% Normalize the concentration field of an image according to a reference
% and calculate the gradients

% UPDATES

% Read image I
ImgI = imread(fullfile(rawImgPath, rawImgFiles(frIdx).name));

% convert to double
ImgI = double(ImgI)./(2^16-1);

% crop the middle part of the mask
if cropMiddle
ImgI = ImgI(imgRange{1}, imgRange{2});
refImg = refImg(imgRange{1}, imgRange{2});
grainMask = grainMask(imgRange{1}, imgRange{2});
unsatMaskImg = unsatMaskImg(imgRange{1}, imgRange{2});
end

% Omit the air clusters from the grain mask
grainMaskUnsat = grainMask;
grainMaskUnsat(unsatMaskImg) = 0;

% Normalize the concentration based on a reference image
C = zeros(size(ImgI));
C(grainMaskUnsat) = ImgI(grainMaskUnsat)./refImg(grainMaskUnsat);
% Apply filter to smooth the image and improve analysis
C = fmg(C,5);

% Calculate gradients using the Sobel-Feldman operator with a 3-by-3
% smoothing matrix. Also calculate the
% angles of the gradient line.
[~, thetaG] = GradientNormAngles(C);
% Calculate gradients without smoothing
[Gx, Gy] = gradient(C);
G = sqrt(Gx.^2 + Gy.^2);

% Remove the grains with the improved mask
C(~grainMaskUnsat) = 0;
% Remove low intensity noise
C(C<0) = 0;
% Save a 16-bit image of the concentrations
C16 = uint16(C*(2^16-1));
imwrite(C16, fullfile(concImgsFolder, sprintf('C16_fr_%03d.png', frIdx)))

% Find all concentration pixels between 5%-95%
CLabel = bwlabel(C<(mixZoneMaxC) & C>(mixZoneMinC));
% Calculate the properties of the regions
rp = regionprops(CLabel);
% Find the largest region
[~, mainIdx] = max([rp.Area]);
% Define the mixing zone
mixZone = CLabel==mainIdx;
% Define a "tight" mixing zone around the contour of the region of changing
% concentrations
[mixZoneTight] = ImageSubsetRegion(C, (1-mixZoneMaxC), mixZoneMaxC);
% Define the mixing zone as a rectangle, defined by the extreme x-values of the
% tight mixing zone 
[y, mixZoneX] = find(mixZoneTight);
mixZoneXMax = max(mixZoneX);
mixZoneXMin = min(mixZoneX);
mixZone = false(size(mixZoneTight));
mixZone(:,mixZoneXMin:mixZoneXMax) = grainMaskUnsat(:,mixZoneXMin:mixZoneXMax);
% Remove the first pore length
mixZone(:,1:40) = false;


G(1:3,:) = 0;
G(end-2:end,:) = 0;
G(:,1:3) = 0;
G(:,end-2:end) = 0;
G(~grainMaskUnsat) = 0;
% G(mk) = 0;
G = real(G);
G = G./pixLen;
% Collect the gradient values only in the mixing zone
G = G.*mixZone;
% Save a 16-bit image of the Gradients
G16 = uint16(G);
imwrite(G16, fullfile(gradImgsFolder, sprintf('G16_fr_%03d.png', frIdx)))

% Find the index of pixels which are saturated or are probably background noise
Gtot = G(grainMaskUnsat);
% For the mean gradient calculation, I don't take into account the pixels
% with no gradients
Gtot = nonzeros(Gtot);
% Calculate the pdf of the concentration gradient
[N,gradEdges] = histcounts(Gtot(:), size(gradPDF,2));
% Save the bin counts
gradBinCount(frIdx,:) = N;
% Calculate the gradient PDF:
gradPDF(frIdx,:) = N./trapz(cumsum(diff(gradEdges)),N);
gradPDFEdges(frIdx,:) = gradEdges;
% Save the mean gradient value
saveMeanGrad(frIdx) = mean(Gtot);
% Save the maximum gradient value
saveMaxGrad(frIdx) = max(Gtot);

end