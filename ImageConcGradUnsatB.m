function [C, G, gradBinCount, gradPDF, gradPDFEdges, ...
    saveMeanGrad, saveMaxGrad, mixZone] = ImageConcGradUnsatB...
    (Cmax, frIdx, grainMaskUnsat, refImg, concImgsFolder, gradImgsFolder, Csup_ratio, ...
    Cinf_ratio, gradBinCount, gradPDF, gradPDFEdges, saveMeanGrad, saveMaxGrad, ...
    cropMiddle, imgRange)

% CALCULATES IMAGE CONCCENTRATION AND GRADIENTS FOR UNSATURATED FLOW
% EXPERIMENTS
% Calculate the concentration and gradients in an image of the experiment,
% starting with a saved analyzed 16 bit png of the concentrations and the
% gradients.


% UPDATES
% 15/07/2021: I added a correction for the concentration images for the
% improved grain mask

% The option to plot the loaded images
plotIm = 0;

% Load the 16 bit images
[C16, G16] = Open16bitImgUnsat(frIdx, plotIm, concImgsFolder, gradImgsFolder, 1, 1);

imread(fullfile(analyzImgFoldC, sprintf('C16_fr_%03d.png', imgIdx)));

% convert them back to double variables
G = double(G16);
C = double(C16)/(2^16-1)*Cmax;

% Set the portion of the image to use
if cropMiddle
    grainMaskUnsat = grainMaskUnsat(imgRange{1}, imgRange{2});
    G = G(imgRange{1}, imgRange{2});
    C = C(imgRange{1}, imgRange{2});
end

% % Correct the concentration image
% C = C.*grainMaskUnsat;
% Find all concentration pixels between 5%-95%
CLabel = bwlabel(C<(Csup_ratio*Cmax) & C>(Cinf_ratio*Cmax));
% Calculate the properties of the regions
rp = regionprops(CLabel);
% Find the largest region
[~, mainIdx] = max([rp.Area]);
% Define the mixing zone
mixZone = CLabel==mainIdx;
%%%%% 24/06/2021
% Define a "tight" mixing zone around the contour of the region of changing
% concentrations
[mixZoneTight] = ImageSubsetRegion(C, (1-Csup_ratio)*Cmax, Csup_ratio*Cmax);
% Define the mixing zone as a rectangle, defined by the extreme x-values of the
% tight mixing zone 
[y, mixZoneX] = find(mixZoneTight);
mixZoneXMax = max(mixZoneX);
mixZoneXMin = min(mixZoneX);
mixZone = false(size(mixZoneTight));
mixZone(:,mixZoneXMin:mixZoneXMax) = grainMaskUnsat(:,mixZoneXMin:mixZoneXMax);
% Remove the first pore length
mixZone(:,1:40) = false;
%%%%% 24/06/2021
% Collect the gradient values only in the mixing zone
G = G.*mixZone;

% Find the index of pixels which are saturated or are probably background noise
Gtot = G(grainMaskUnsat);
% For the mean gradient calculation, I don't take into account the pixels
% with no gradients
Gtot = nonzeros(Gtot);
% Calculate the gradients > the 60th percentile
G60 = Gtot(Gtot>prctile(Gtot, 60));
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

