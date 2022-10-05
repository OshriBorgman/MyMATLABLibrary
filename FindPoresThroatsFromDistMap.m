M = grainMask(800:1000, 800:1000);
% Calculate the distance map
distMap = imfilter(bwdist(~M), ones(3)./3^2);
% skeletonize the distance map to find the throat ridgelines
distMapSkel = bwskel(logical(distMap));
% The distances on the skeleton
distSkel = distMap.*distMapSkel;
% create a tree model of the points in the skeleton:
[XSkelY, XSkelX] = find(distMapSkel);
treeMdl = KDTreeSearcher([XSkelX, XSkelY]);
% Define the search distance in pixels for local minima and maxima
searDist = 10;
% Find minimum and maximum points at certain distance from the 
locMin = [];
nMin = 0;
locMax = [];
nMax = 0;
for i = 1:length(XSkelY)
    % The list of the neighbors
    neighbors = rangesearch(treeMdl, [XSkelX(i), XSkelY(i)], searDist);
    % The neighbor indices
    neighIdx = sub2ind(size(distMap), treeMdl.X(neighbors{:},2), ...
        treeMdl.X(neighbors{:},1));
    %The point index
    querIdx = sub2ind(size(distMap), XSkelY(i), XSkelX(i));
    % exclude the point 
    neighIdx(neighIdx==querIdx) = [];
    % Plot the point and the neighbors
    figure(11)
    clf
    hold on
    imagesc(distMap); axis equal tight
    querPntMat = false(size(distMap));
    querPntMat(querIdx) = true;
    spy(querPntMat, 'r')
    neighPntsMat = false(size(distMap));
    neighPntsMat(neighIdx) = true;
    spy(neighPntsMat, 'b')
    % The distances of the neighbors
    distNeigh = distSkel(neighIdx);
    % Find if it's a minimum or maximum
    if all(distSkel(querIdx)<distNeigh)
        nMin = nMin + 1;
        locMin(nMin).Idx = querIdx;
        [querSubRow, querSubCol] = ind2sub(size(distMap), querIdx);
        locMin(nMin).X(:) = [querSubCol, querSubRow];
        locMin(nMin).distance = distMap(querIdx);
    elseif all(distSkel(querIdx)>distNeigh)
        nMax = nMax + 1;
        locMax(nMax).Idx = querIdx;
        [querSubRow, querSubCol] = ind2sub(size(distMap), querIdx);
        locMax(nMax).X(:) = [querSubCol, querSubRow];
        locMax(nMax).distance = distMap(querIdx);
    end
end
    
% Plot the throats and pores
figure(12)
clf
hold on
imagesc(distMap); axis equal tight
minPnts = false(size(distMap));
minPnts([locMin.Idx]) = true;
spy(minPnts, 'k')
maxPnts = false(size(distMap));
maxPnts([locMax.Idx]) = true;
spy(maxPnts, 'g')