function [C, G, gradBinCount, gradEdges, saveMeanGrad, mixZone, VmWidth, VmArea] = ...
    ImageConcGradUnsat(Cmax, Cmin, n, grainMaskUnsat, grainMaskDil, concImgsFolder, ...
    gradImgsFolder, Csup_ratio, Cinf_ratio, gradBinCount, gradEdges, saveMeanGrad, ...
    imgName, VmWidth, VmArea, pixL)

% CALCULATES IMAGE CONCCENTRATION AND GRADIENTS FOR UNSATURATED FLOW
% EXPERIMENTS
% Calculate the concentration and gradients in an image of the experiment,
% starting with a saved analyzed 16 bit png of the concentrations and the
% gradients.


% UPDATES
% 15/07/2021: I added a correction for the concentration images for the
% improved grain mask
% 12/12/2021: I omitted the 'cropMiddle' parameter
% 12/12/2021: I'm loading the images directly from the folder, using the
% list of images

% Load the 16 bit images
C16 = imread(fullfile(concImgsFolder, imgName));
G16 = imread(fullfile(gradImgsFolder, ['G' imgName(2:end)]));


% convert them back to double variables
G = double(G16)*Cmax;
C = double(C16)/(2^16-1)*Cmax;

% Remove the air clusters from the concentration image
C(~grainMaskUnsat) = 0;

%%%%% 24/06/2021
% Define a "tight" mixing zone around the contour of the region of changing
% concentrations
[mixZoneTight] = ImageSubsetRegion(C, (1-Csup_ratio)*(Cmax-Cmin)+Cmin, Csup_ratio*(Cmax-Cmin)+Cmin);
% Define the mixing zone as a rectangle, defined by the extreme x-values of the
% tight mixing zone 
[y, mixZoneX] = find(mixZoneTight);
mixZoneXMax = max(mixZoneX);
mixZoneXMin = min(mixZoneX);
mixZone = false(size(mixZoneTight));
mixZone(:,mixZoneXMin:mixZoneXMax) = grainMaskUnsat(:,mixZoneXMin:mixZoneXMax);
% % Remove the first pore length
% mixZone(:,1:40) = false;
% %%%%% 24/06/2021
% % Collect the gradient values only in the mixing zone
% G = G.*mixZone;
%%%%%% 16/12/2021
% % Use a dilated grain mask for the gradients
% G = G.*mixZone.*grainMaskDil;
% %%%%% 17/12/2021
% mixZone = mixZoneTight;

% Use a dilated grain mask for the gradients and the tight mixing zone
G = G.*mixZone.*grainMaskDil;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Clean the gradient image
% [gradMask] = CleanGradImage(G);
% G = G.*gradMask;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove the edges of the gradient image
G([1:3 end-2:end], :) = 0;
G(:, 1:3) = 0;
% The vector of gradient values
Gtot = G(grainMaskUnsat);
% For the mean gradient calculation, I don't take into account the pixels
% with no gradients
Gtot = nonzeros(Gtot);
% Calculate the gradients > the 60th percentile
G60 = Gtot(Gtot>prctile(Gtot, 60));
% Calculate the pdf of the concentration gradient
[N,gradEdges] = histcounts(Gtot(:), size(gradBinCount,2));
% Save the bin counts
gradBinCount(n,:) = N;
% Calculate the gradient PDF:
gradEdges(n,:) = gradEdges;
% Save the mean gradient value
saveMeanGrad(n) = mean(Gtot);

% the width of the mixing zone
width = zeros(size(mixZone, 1), 1);
for ii = 1:length(width)
    if ~isempty(find(mixZone(ii,:), 1, 'first'))
        width(ii) = find(mixZone(ii,:), 1, 'last') - find(mixZone(ii,:), 1, 'first');
    end
end
VmWidth(n) = mean(width)*pixL;
VmArea(n) = sum(mixZone, "all").*pixL.*pixL;

end



