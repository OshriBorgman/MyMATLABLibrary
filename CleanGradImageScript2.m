%% Clean the gradient image

modelFits = [];
meanGrad = [];

for frIdx = [15:25];

% Load the 16 bit images
C16 = imread(fullfile(analyzImgsFolderConc, conImgFiles(frIdx).name));
G16 = imread(fullfile(analyzImgsFolderGrad, ['G' conImgFiles(frIdx).name(2:end)]));


% convert them back to double variables
G = double(G16)*CMax;
C = double(C16)/(2^16-1)*CMax;

[mixZoneTight] = ImageSubsetRegion(C, 0.05*(CMax-CMin)+CMin, 0.95*(CMax-CMin)+CMin);
% Define the mixing zone as a rectangle, defined by the extreme x-values of the
% tight mixing zone 
[y, mixZoneX] = find(mixZoneTight);
mixZoneXMax = max(mixZoneX);
mixZoneXMin = min(mixZoneX);
mixZone = false(size(mixZoneTight));
mixZone(:,mixZoneXMin:mixZoneXMax) = unsatMaskImg(:,mixZoneXMin:mixZoneXMax);

% % Step 1: low pass filter
G11 = G;
PlotFieldImage(G11.*grainMaskDil.*mixZone, 'G12.*grainMaskDil.*mixZone');
caxis([0 50000])
figure; histogram(nonzeros(G11(grainMaskDil(mixZone))), 'BinWidth', 1e3)
[h, b] = histcounts(nonzeros(G11(grainMaskDil(mixZone))), 'BinWidth', 1e3);
% Get rid of low background noise
[mx,ix] = max(h);
% Threshold to remove some small values
GThresh2 = G11>b(ix);

% % Step 2: high pass filter
G12 = G11.*GThresh2;
PlotFieldImage(G12.*grainMaskDil.*mixZone, 'G12.*grainMaskDil.*mixZone');
caxis([0 50000])
figure; histogram(nonzeros(G11(grainMaskDil(mixZone))), 'BinWidth', 1e3)
[h, b] = histcounts(nonzeros(G11(grainMaskDil(mixZone))), 'BinWidth', 1e3);
% Get rid of low background noise
[mx,ix] = max(h);
% Threshold to remove some small values
GThresh2 = G11>b(ix);

% 
% % % Step 2: morphological functions to isolate gradients and remove
% % % non-gradient patches
% % Set the parameters for the morphological functions
% rEr = 4;
% % Use line elements at different orientations
% GOpen = imopen(GThresh2, strel('line',rEr,90));
% GOpen = imopen(GOpen, strel('line',rEr,0));
% GOpen = imopen(GOpen, strel('line',rEr,45));
% % Obtain the properties of the non-aqueous phase
% gradImgBWLabel = bwlabel(GOpen);
% gradImgBWProps = regionprops(gradImgBWLabel, "Orientation", "Area", "Circularity");
% % Remove small clusters
% excludeClusters = find(abs([gradImgBWProps.Area])<30);
% gradImgBWLabel2 = gradImgBWLabel;
% gradImgBWLabel2(ismember(gradImgBWLabel,excludeClusters)) = 0;
% % Remove clusters not oriented perpendicular to the flow direction
% excludeClusters = find(abs([gradImgBWProps.Orientation])>45) ;
% gradImgBWLabel3 = gradImgBWLabel2;
% gradImgBWLabel3(ismember(gradImgBWLabel2,excludeClusters)) = 0;
% % Remove circular objects
% excludeClusters = find([gradImgBWProps.Circularity]>0.8);
% gradImgBWLabel4 = gradImgBWLabel3;
% gradImgBWLabel4(ismember(gradImgBWLabel3,excludeClusters)) = 0;
% 


end