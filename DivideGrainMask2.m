function [maskParts] = DivideGrainMask2(mk, boundaries)

% DIVIDE GRAIN MASK Divide a grain mask (image of circular disks) in three
% zones

% NOTE: This procedure misses a few partial grains, mostly on one of the
% sides of the cell, which are not very important

% INPUT
% mk: the full grain mask
% boundaries: a vector of boundaries for the different parts

% Find the grain position in the mask
[grainPos, ~] = imfindcircles(mk, [10 25]);

% Initiate the partial masks
for k = 1:length(boundaries)-1
maskParts{k} = zeros(size(mk));
end

% Label the regions (grains); use this to identify the grains that would be
% added to the partial masks
labeledMask = bwlabel(mk);
% Identify the centroids
maskGrainProps = regionprops(bwlabel(mk), 'Centroid');
% Collect x- and y-coordinates
allCentroids = [maskGrainProps.Centroid];
xCentroids = allCentroids(1:2:end);
yCentroids = allCentroids(2:2:end);

% For each grain identified by imfindcircles
for i = 1:length(grainPos)
% The position of the current grain
X = grainPos(i,:);
% The vector of distances from the other grains
dist = sqrt(sum([(xCentroids'-X(:,1)).^2 (yCentroids'-X(:,2)).^2], 2));
% The index of the region with the smallest distance to the current grain
[~, maskGrainIdx] = min(dist);
% Add the grain to one of the partial masks
for k = 1:length(boundaries)-1
if X(1)>=boundaries(k) && X(1)<boundaries(k+1)
maskParts{k}(find(labeledMask==maskGrainIdx)) = true;
end
end
end

end

