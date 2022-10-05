M = ~grainMaskTrim;%(301:700, 1001:1400);

% Calculate the distance map and skeletonize
[distMap, distMapSkel, distSkel] = SkelFromDistMap(M, 3);

% create a tree model of the points in the skeleton:
[XSkelY, XSkelX] = find(distMapSkel);
treeMdl = KDTreeSearcher([XSkelX, XSkelY]);
% Define the search distance in pixels for local minima and maxima
searDist = 15;

%% Find minimum and maximum points 
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
    % Plot the point and the neighbors
%     figure(11)
%     clf
%     hold on
%     imagesc(distMap); axis equal tight
%     querPntMat = false(size(distMap));
%     querPntMat(querIdx) = true;
%     neighPntsMat = false(size(distMap));
%     neighPntsMat(neighIdx) = true;
%     spy(neighPntsMat, 'b')
%     spy(querPntMat, 'r')
    % The distances of the neighbors
    distNeigh = distSkel(neighIdx);
    % Find if it's a minimum or maximum
    if distSkel(querIdx)==min(distNeigh)
        nMin = nMin + 1;
        locMin(nMin).Idx = querIdx;
        [querSubRow, querSubCol] = ind2sub(size(distMap), querIdx);
        locMin(nMin).X(:) = [querSubCol, querSubRow];
        locMin(nMin).distance = distMap(querIdx);
    elseif distSkel(querIdx)==max(distNeigh)
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

%% Remove redundant/duplicate throats
% construct a tree of max points
maxPntsTreeMdl = KDTreeSearcher(reshape([locMax.X], 2, length(locMax))');
% construct a tree of min points
minPntsTreeMdl = KDTreeSearcher(reshape([locMin.X], 2, length(locMin))');
% The shortlisted minimum points
locMinShort = locMin;
% for each min point check if there are other min points less than
% 'searDist' away. Keep the point with the largest distance from the two
% closest max points
i = 1;
while i<length(locMinShort)
    % construct a tree of max points
    maxPntsTreeMdl = KDTreeSearcher(reshape([locMax.X], 2, length(locMax))');
    % construct a tree of min points
    minPntsTreeMdl = KDTreeSearcher(reshape([locMinShort.X], 2, length(locMinShort))');
    % The neighbor max points
    neighborMaxPnts = knnsearch(maxPntsTreeMdl, [locMinShort(i).X(1), ...
        locMinShort(i).X(2)], 'K', 2);
    % Find min points within searDist
    neighborMinPnts = rangesearch(minPntsTreeMdl, [locMinShort(i).X(1), ...
        locMinShort(i).X(2)], searDist);
    if length(neighborMinPnts{:})>1
        % Calculate the distances between the min points to the first max
        % point
        dist1 = sqrt(sum((reshape([locMinShort(neighborMinPnts{:}).X],2,...
            length(neighborMinPnts{:}))-[locMax(neighborMaxPnts(1)).X]').^2));
        % Calculate the distances between the min points to the first max
        % point
        dist2 = sqrt(sum((reshape([locMinShort(neighborMinPnts{:}).X],2,...
            length(neighborMinPnts{:}))-[locMax(neighborMaxPnts(2)).X]').^2));
        % Calculate the absolute differences between the two distances
        distDiff = abs(dist1-dist2);
        % Find the minimum absolute difference, to indicate the point in
        % the middle of the throat
        [m, idx] = min(distDiff);
        % Remove all the redundant points from the min points shortlist
        neighborMinPnts{:}(idx)=[];
        locMinShort(neighborMinPnts{:}) = [];
    end
    i = i+1;
end

% Plot the remaining throats and pores
figure(13)
clf
hold on
imagesc(distMap); axis equal tight
minPnts = false(size(distMap));
minPnts([locMinShort.Idx]) = true;
spy(minPnts, 'k')
maxPnts = false(size(distMap));
maxPnts([locMax.Idx]) = true;
spy(maxPnts, 'g')

%% Remove min points larger than distance to adjacent max points
% % The minimum points which have higher distance to wall than to an
% adjacent maximum are not real minimum. Remove also one of the adjacent
% pores, to unify the pores
% construct a tree of max points
maxPntsTreeMdl = KDTreeSearcher(reshape([locMax.X], 2, length(locMax))');
% The shortlisted minimum points
locMinShorter = locMinShort;
i = 1;
while i<length(locMinShorter)
    % construct a tree of min points
    minPntsTreeMdl = KDTreeSearcher(reshape([locMinShorter.X], 2, length(locMinShorter))');
    % The neighbor max points
    neighborMaxPnts = knnsearch(maxPntsTreeMdl, [locMinShorter(i).X(1), ...
        locMinShorter(i).X(2)], 'K', 2);
    % Calculate the distances between the min point to the first max
    % point
    dist1 = sqrt(sum((reshape([locMinShorter(i).X],2,1) - ...
        [locMax(neighborMaxPnts(1)).X]').^2));
    % Calculate the distances between the min points to the second max
    % point
    dist2 = sqrt(sum((reshape([locMinShorter(i).X],2,1) - ...
        [locMax(neighborMaxPnts(2)).X]').^2));
    if any([dist1<locMinShorter(i).distance dist2<locMinShorter(i).distance])
        % Remove all the redundant points from the min points shortlist
        locMinShorter(i) = [];
        % Remove the smaller pore between the pair, to unite the two pores
        % into one
        [~, idx] = min([locMax(neighborMaxPnts).distance]);
        % Remove all the redundant points from the min points shortlist
        neighborMaxPnts(idx) = [];
        locMax(neighborMaxPnts) = [];
        % construct a tree of max points
        maxPntsTreeMdl = KDTreeSearcher(reshape([locMax.X], 2, length(locMax))');
    end
    i = i+1;
end

% Plot the remaining throats and pores
figure(14)
clf
hold on
imagesc(distMap); axis equal tight
minPnts = false(size(distMap));
minPnts([locMinShorter.Idx]) = true;
spy(minPnts, 'k')
maxPnts = false(size(distMap));
maxPnts([locMax.Idx]) = true;
spy(maxPnts, 'g')

%% Remove min points with larger distance than adjacent max points
% % The minimum points which have higher distance to wall than the distance
% to wall of an adjacent maximum are not real minimum
% construct a tree of max points
maxPntsTreeMdl = KDTreeSearcher(reshape([locMax.X], 2, length(locMax))');
% The shortlisted minimum points
locMinShortest = locMinShorter;
i = 1;
while i<length(locMinShortest)
    % construct a tree of min points
    minPntsTreeMdl = KDTreeSearcher(reshape([locMinShortest.X], 2, length(locMinShortest))');
    % The neighbor max points
    neighborMaxPnts = knnsearch(maxPntsTreeMdl, [locMinShortest(i).X(1), ...
        locMinShortest(i).X(2)], 'K', 2);
    if any([locMax(neighborMaxPnts).distance]<locMinShortest(i).distance)
        % Remove the redundant point from the min points shortlist
        locMinShortest(i) = [];
        % Remove the smaller pore between the pair
        [~, idx] = min([locMax(neighborMaxPnts).distance]);
        % Remove all the redundant points from the min points shortlist
        neighborMaxPnts(idx) = [];
        locMax(neighborMaxPnts) = [];
        % construct a tree of max points
        maxPntsTreeMdl = KDTreeSearcher(reshape([locMax.X], 2, length(locMax))');
    end
    i = i+1;
end

% Plot the remaining throats and pores
figure(15)
clf
hold on
imagesc(distMap); axis equal tight
minPnts = false(size(distMap));
minPnts([locMinShortest.Idx]) = true;
spy(minPnts, 'k')
maxPnts = false(size(distMap));
maxPnts([locMax.Idx]) = true;
spy(maxPnts, 'g')

%% Remove two maxima which are too close - TO IMPROVE
% % If a maxima has another maxima closer than the closest minima, the
% smaller maxima is redundant
% construct a tree of min points
minPntsTreeMdl = KDTreeSearcher(reshape([locMinShortest.X], 2, length(locMinShortest))');
% The shortlisted maximum points
locMaxShorter = locMax;
i = 1;
while i<length(locMaxShorter)
    % construct a tree of max points
    maxPntsTreeMdl = KDTreeSearcher(reshape([locMaxShorter.X], 2, length(locMaxShorter))');
    % The neighbor max points
    neighborMaxPnts = knnsearch(maxPntsTreeMdl, [locMaxShorter(i).X(1), ...
        locMaxShorter(i).X(2)], 'K', 2);
    % The neighbor min points
    neighborMinPnts = knnsearch(minPntsTreeMdl, [locMaxShorter(i).X(1), ...
        locMaxShorter(i).X(2)], 'K', 1);
    % Calculate the distance to the min point 
    distMin = sqrt(sum(([locMaxShorter(i).X] - [locMinShortest(neighborMinPnts).X]).^2));
    % Calculate distance to the max point
    distMax = sqrt(sum(([locMaxShorter(i).X] - [locMaxShorter(neighborMaxPnts(2)).X]).^2));
    if distMin>distMax
        % Find the larger maximum
        [~, idx] = max([locMaxShorter(neighborMaxPnts).distance]);
        % Remove the larger maximum from the shortlist
        neighborMaxPnts(idx) = [];
        % Remove the index in the shortlist
        locMaxShorter(neighborMaxPnts) = [];
    end
    i = i+1;
end

% Plot the remaining throats and pores
figure(16)
clf
hold on
imagesc(distMap); axis equal tight
minPnts = false(size(distMap));
minPnts([locMinShortest.Idx]) = true;
spy(minPnts, 'k')
maxPnts = false(size(distMap));
maxPnts([locMaxShorter.Idx]) = true;
spy(maxPnts, 'g')


%% Plot distributions

figure(21)
histogram([locMinShortest.distance]*0.023, 'Normalization', 'pdf')
