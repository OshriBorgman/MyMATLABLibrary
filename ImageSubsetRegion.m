function [subsetMat, subsetZone] = ImageSubsetRegion(matInput, lowThresh, highThresh)

%IMAGE SUBSET REGION Find the subset pixels of an image matrix, defined by
% a lower and high threshold

% INPUT
% matInput: the input array, a double
% lowThresh: the low threshold defining the region of interest, all values
% below will not be included
% highThresh: the high threshold defining the region of interest, all values
% above will not be included

% UPDATES
% 19/12/2021: Change the upper boundary to <=, to capture the cluster of
% logical arrays
% 08/03/2022: I included the rectangular subset region in the function
% 18/10/2022: Create a line of pixel connecting the left, upper and lower
% boundaries, to treat fractional (unsaturated) cluster patterns

% Connect the boundaries of the image to include separate clusters
% in the tight zone
matInput(:, 1) = lowThresh;
% Add the side boundaries to account for clusters disconnected from the
% inlet due to image cropping
matInput([1 end], :) = lowThresh;
% matInput([1 end], :) = lowThresh;
% Find all pixels between threshold values
matLabel = bwlabel(matInput>=(lowThresh) & matInput<=(highThresh));
% Calculate the properties of the regions
rp = regionprops(matLabel);
% Find the largest region
[~, mainIdx] = max([rp.Area]);
% Define the subset region
subsetMat = matLabel==mainIdx;
% Remove the bands on the sides to not affect the rectangular region
subsetMat(:, [1 end]) = false;
% subsetMat([1 end], :) = false;

% Define a rectangular subset using the limits of the tight subset
[y, x] = find(subsetMat);
subsetMatXMax = max(x);
subsetMatXMin = min(x);
subsetZone = false(size(subsetMat));
subsetZone(:,subsetMatXMin:subsetMatXMax) = true;

end

