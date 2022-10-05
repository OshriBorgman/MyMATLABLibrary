function [selectedSegments2, allLengthsThresh2, selectedGrainsDiam2, nSeg2, selectInd2] = ...
    CalculateThroatApertures2D(xGr, dGr, plotThroatLengthTrans, plotOneEdge, plotEdgesLengths, sampleData)

% CALCULATE THROAT APERTURES IN 2D SAMPLE Calculate the throat apertures in
% a 2-D array of circular disks

% The steps of characterization:
% 1. Create a Delaunay triangulation of all edges
% 2. Filter some length according to a global threshold
% 3. Calculate the ratio between mesh edges locally, and remove edges which
% are significanly large than their neighbors, since they will probably
% not be throats (constrictions)

% INPUT
% xGr: the vector of grain locations
% dGr: the list of grain diameters
% plotThroatLengthTrans: plot the distribution of throat edge lengths and
% find the transition point, default is false
% plotOneEdge: plot an image of one edge and its neighbor grains and edges,
% default is false
% plotEdgesRatios: plot an image of all edges and their length, default is
% false

if nargin<3
    plotThroatLengthTrans = 0;
    plotOneEdge = 0;
    plotEdgesLengths = 0;
end

if nargin<4
    plotOneEdge = 0;
    plotEdgesLengths = 0;
end

if nargin<5
    plotEdgesLengths = 0;
end

%% Create the Delaunay triangulation
DT = delaunayTriangulation(xGr(:,1),xGr(:,2));

% The number of triangles
[nTri,~] = size(DT.ConnectivityList);
%% Compile a list of all edges
allLengths = [];
allSegments = [];
allGrainD = [];

% Collect the list of all triangle edges
for i = 1:nTri
    indPoints = DT.ConnectivityList(i,:);
    
    coord1 = DT.Points(indPoints(1),:);
    coord2 = DT.Points(indPoints(2),:);
    coord3 = DT.Points(indPoints(3),:);
    
    % The grain radius associated with the points
    coord1Dg = dGr(indPoints(1));
    coord2Dg = dGr(indPoints(2));
    coord3Dg = dGr(indPoints(3));
    
    %  The first edge
    l = sqrt((coord2(1)-coord1(1))^2+(coord2(2)-coord1(2))^2);
    l = max(0,l-0.5*dGr(indPoints(1))-0.5*dGr(indPoints(2)));
    allLengths = [allLengths; l];
    allSegments = [allSegments; [coord1(1) coord1(2) coord2(1) coord2(2)]];
    allGrainD = [allGrainD; [coord1Dg coord2Dg]];
    % Second edge
    l = sqrt((coord3(1)-coord1(1))^2+(coord3(2)-coord1(2))^2);
    l = max(0,l-0.5*dGr(indPoints(1))-0.5*dGr(indPoints(3)));
    allLengths = [allLengths; l];
    allSegments = [allSegments; [coord1(1) coord1(2) coord3(1) coord3(2)]];
    allGrainD = [allGrainD; [coord1Dg coord3Dg]];
    % Third edge
    l = sqrt((coord3(1)-coord2(1))^2+(coord3(2)-coord2(2))^2);
    l = max(0,l-0.5*dGr(indPoints(2))-0.5*dGr(indPoints(3)));
    allLengths = [allLengths; l];
    allSegments = [allSegments; [coord2(1) coord2(2) coord3(1) coord3(2)]];
    allGrainD = [allGrainD; [coord2Dg coord3Dg]];
    
end

% Compile a unique list of edges by removing duplicate edges from the list
[m,~] = size(allSegments);
allSegments2 = [];
allGrainD2 = [];
for i = 1:m
    if (allSegments(i,1) > allSegments(i,3))
        allSegments2 = [allSegments2; [allSegments(i,3) allSegments(i,4) allSegments(i,1) allSegments(i,2)]];
        % Arrange the grain radii as well
        allGrainD2 = [allGrainD2; [allGrainD(i,2) allGrainD(i,1)]];
    else
        allSegments2= [allSegments2; allSegments(i,:)];
        allGrainD2 = [allGrainD2; allGrainD(i,:)];
    end
    
end
[allSegments3, ia, ic] = unique(allSegments2, 'rows');
allLengths2 = allLengths(ia, :);
allGrainD3 = allGrainD2(ia, :);

allSegments = allSegments3;
allLengths = allLengths2;
allGrainD = allGrainD3;

%% Filter out some of the edges according to a length threshold

% Remove some edges a-priori, if I consider them too long to be throats
lengthThres = 2*mean(dGr);

selectInd = find(allLengths < lengthThres);
allLengthsThresh = allLengths(selectInd);
selectedSegments = allSegments(selectInd,:);
allGrainRadThresh = allGrainD(selectInd,:);

[nSeg, ~] = size(selectedSegments);


%% Calculate length ratios between neighbor edges
% Calculate the ratio between the length of an edge (or connecting segment)
% and the edges it has in common between the two ends of the segments. The
% number of neighbor segments can vary and depends on a length threshold
% set earlier.
allLenRatios = [];

for count = 1:nSeg
    
    % The coordinates of the edge ends
    x1 = selectedSegments(count, 1);
    y1 = selectedSegments(count, 2);
    x2 = selectedSegments(count, 3);
    y2 = selectedSegments(count, 4);
    % The grain diameters at the nodes
    d1 =  allGrainRadThresh(count,1);
    d2 =  allGrainRadThresh(count,2);
    
    % fprintf('Considering segments of coordinates ( %f , %f ) and ( %f , %f ) \n',x1,y1,x2,y2);
    
    % The edges connected to point 1
    % Find the indices of edges "starting" at point 1
    ind1 = find(selectedSegments(:,1)==x1 & selectedSegments(:,2)==y1);
    % Find their second point
    adjacentsToPoint1 = [selectedSegments(ind1,3) selectedSegments(ind1,4)];
    % Find the indices of edges "ending" at point 1:
    ind2 = find(selectedSegments(:,3)==x1 & selectedSegments(:,4)==y1);
    % Complete the list of all points connected to point 1 by an edge. This
    % variable gives the coordinates of connected points
    adjacentsToPoint1 = [adjacentsToPoint1; [selectedSegments(ind2,1) selectedSegments(ind2,2)]];
    % Find the grain diameters associated with the connected edges
    grainDiaAdjP1 = [allGrainRadThresh(ind1,2); allGrainRadThresh(ind2,1)];
    
    % The edges connected to point 2
    ind1 = find(selectedSegments(:,1)==x2 & selectedSegments(:,2)==y2);
    adjacentsToPoint2 = [selectedSegments(ind1,3) selectedSegments(ind1,4)];
    ind2 = find(selectedSegments(:,3)==x2 & selectedSegments(:,4)==y2);
    adjacentsToPoint2 = [adjacentsToPoint2; [selectedSegments(ind2,1) selectedSegments(ind2,2)]];
    grainDiaAdjP2 = [allGrainRadThresh(ind1,2); allGrainRadThresh(ind2,1)];
    
    % The points commonly connected to both points 1 and 2
    [adjacentToSegment, i1, i2] = intersect(adjacentsToPoint1, adjacentsToPoint2, 'rows');
    % The grain diameters at these points
    dAdjToSeg = grainDiaAdjP1(i1);
    
    % Calculate the ratio between the current THROAT and the THROATS related to the common points
    [m, ~] = size(adjacentToSegment);
    % Check if there are common points
    if m > 0
        l1 = [];
        l2 = [];
        % For each common point
        for j = 1:m
            % The length of the CONSTRICTION between point 1 and common point j
            length1 = ((x1-adjacentToSegment(j,1))^2 + (y1-adjacentToSegment(j,2))^2)^0.5 - ...
                (d1+dAdjToSeg(j))/2;
            % The length of the CONSTRICTION between point 2 and common point j
            length2 = ((x2-adjacentToSegment(j,1))^2 + (y2-adjacentToSegment(j,2))^2)^0.5 - ...
                (d2+dAdjToSeg(j))/2;
            % Collect the lengths
            l1 = [l1; length1];
            l2 = [l2; length2];
        end
        
        % Sort the lengths of the adjacent constrictions
        l1and2 = sort([l1;l2]);
        % Calculate the length of the current constriction
        l = ((x1-x2)^2 + (y1-y2)^2)^0.5 - (d1+d2)/2;
% %         30-06-2022: Set l = 0 if l < 0 (when grains apear to be
% touching)
        if l < 0
            l = 0;
        end
        
        % Calculate the ratio between the current edge and the two shorter edges
        % which are adjacent
        if m==1
            lRatio = l/l1and2(1);
        else
            lRatio = l/mean(l1and2(1:2));
        end
        
    elseif m==0
        
        lRatio = 0;
        
    end
    
    % Append the result to the list of all ratios
    allLenRatios = [allLenRatios; lRatio];
    
end

if plotOneEdge
    %% Highlight one edge and its connected points
    % Select the edge to plot around
    count  = 1000;
    
    % The coordinates of the edge ends
    x1 = selectedSegments(count, 1);
    y1 = selectedSegments(count, 2);
    x2 = selectedSegments(count, 3);
    y2 = selectedSegments(count, 4);
    
    % The edges connected to point 1
    % Find the indices of edges "starting" at point 1
    ind1 = find(selectedSegments(:,1)==x1 & selectedSegments(:,2)==y1);
    % Find their second point
    adjacentsToPoint1 = [selectedSegments(ind1,3) selectedSegments(ind1,4)];
    % Find the indices of edges "ending" at point 1:
    ind2 = find(selectedSegments(:,3)==x1 & selectedSegments(:,4)==y1);
    % Complete the list of all points connected to point 1 by an edge. This
    % variable gives the coordinates of connected points
    adjacentsToPoint1 = [adjacentsToPoint1; [selectedSegments(ind2,1) selectedSegments(ind2,2)]];
    
    % The edges connected to point 2
    ind1 = find(selectedSegments(:,1)==x2 & selectedSegments(:,2)==y2);
    adjacentsToPoint2 = [selectedSegments(ind1,3) selectedSegments(ind1,4)];
    ind2 = find(selectedSegments(:,3)==x2 & selectedSegments(:,4)==y2);
    adjacentsToPoint2 = [adjacentsToPoint2; [selectedSegments(ind2,1) selectedSegments(ind2,2)]];
    
    % The common connected points
    adjacentToSegment=intersect(adjacentsToPoint1, adjacentsToPoint2, 'rows');
    
    % Select the figure with the grains and the edges
    figure
    ax = gca;
    hold on
    % Highlight the selected edge
    plEdge = plot(selectedSegments(count,[1 3]), selectedSegments(count,[2 4]), 'g', "LineWidth", 1, ...
        "DisplayName", "Edge");
    % Highlight the adjacent edges
    [m, ~] = size(adjacentToSegment);
    if m > 0
        % For each common point
        for j = 1:m
            % The edge between point 1 and common point j
            plEdgeAdj = plot([x1 adjacentToSegment(j,1)], [y1 adjacentToSegment(j,2)], 'm', ...
                "LineWidth", 1, "DisplayName", "Adjacent edge");
            % The edge between point 2 and common point j
            plEdgeAdj = plot([x2 adjacentToSegment(j,1)], [y2 adjacentToSegment(j,2)], 'm', ...
                "LineWidth", 1, "DisplayName", "Adjacent edge");
        end
    end
    % Plot the grains
    for p = 1:length(dGr)
        rectangle('Position',[xGr(p,1)-dGr(p)/2 xGr(p,2)-dGr(p)/2 dGr(p) dGr(p)], 'Curvature', [1 1], "FaceColor", [0.5 0.5 0.5], ...
            "EdgeColor", "none")
    end
    % Highlight the points connecteds to point 1
    plConPoint1 = plot(adjacentsToPoint1(:,1), adjacentsToPoint1(:,2), 'h', "MarkerSize", 6, ...
        "MarkerFaceColor", 'r', "MarkerEdgeColor", 'r', "DisplayName", 'Connected to point 1');
    % Highlight the points connected to point 2
    plConPoint2 = plot(adjacentsToPoint2(:,1), adjacentsToPoint2(:,2), 'h', "MarkerSize", 6, ...
        "MarkerFaceColor", 'b', "MarkerEdgeColor", 'b', "DisplayName", 'Connected to point 2');
    % Highlight point 1
    plPoint1 = plot(x1, y1, 'o', "MarkerSize", 5, "MarkerFaceColor", 'r', "MarkerEdgeColor", 'r', ...
        "DisplayName", 'Point 1');
    % Highlight point 2
    plPoint2 = plot(x2, y2, 'o', "MarkerSize", 5, "MarkerFaceColor", 'b', "MarkerEdgeColor", 'b', ...
        "DisplayName", 'Point 2');
    % Highlight the points common to both points 1 and 2
    plComPoint = plot(adjacentToSegment(:,1), adjacentToSegment(:,2), 'o', "MarkerFaceColor", 'g', "MarkerEdgeColor", 'g', ...
        "DisplayName", "Common points");
    axis equal tight
    legend([plEdge plEdgeAdj plConPoint1 plConPoint2 plPoint1 plPoint2 plComPoint], 'location', "bestoutside")
    ax.XLim = [min([adjacentsToPoint1(:,1); adjacentsToPoint2(:,1)]) max([adjacentsToPoint1(:,1); adjacentsToPoint2(:,1)])];
    ax.YLim = [min([adjacentsToPoint1(:,2); adjacentsToPoint2(:,2)]) max([adjacentsToPoint1(:,2); adjacentsToPoint2(:,2)])];
    
end

if plotEdgesLengths
    %% Plot the edges with their ratio values
    % The overall throat size range
    throatSizeRange = [0.05 0.8];
    % The maximum grain size
    throatSizeMax = 0.8;
    % Use a colormap for the grains according to their size
    cMapGrainSize = hot(256);
    
    [~, allLenRatiosOrder] = sort(allLenRatios);
    allLenRatiosSort = allLenRatios(allLenRatiosOrder);
    selectedSegmentsSort = selectedSegments(allLenRatiosOrder,:);
    
    figure
    clf
    ax = gca;
    cmap = colormap(hot(nSeg*10));
    cmapLims = [min(cmap); max(cmap)];
    axis equal
    hold on
    % Plot the grains
    for p = 1:length(dGr)
        rectangle('Position',[xGr(p,1)-dGr(p)/2 xGr(p,2)-dGr(p)/2 dGr(p) dGr(p)], 'Curvature', [1 1], ...
            "FaceColor", [0.5 0.5 0.5], "EdgeColor", 'none')
    end
    % Plot the throats.
    for s = 1:length(allLengthsThresh)
        % Define the color of the throat according to the its length
        colEdge = round(interp1([min(allLenRatios); max(allLenRatios)], [1 length(cmap)], ...
            allLenRatiosSort(s)));
        plot(selectedSegmentsSort(s,[1 3]), selectedSegmentsSort(s,[2 4]), "Color", ...
            cmap(colEdge,:), "LineWidth", 2)
        
        % plot(selectedSegmentsSort(s,[1 3]), selectedSegmentsSort(s,[2 4]), "Color", ...
        %         cMapGrainSize(min(round((allLengthsThresh(s)-throatSizeRange(1))./(throatSizeRange(2)-throatSizeRange(1))*256), 256),:), ...
        %         "LineWidth", 2)
    end
    caxis([min(allLenRatios) max(allLenRatios)])
    c = colorbar;
    axis equal tight
    c.TickLabels = [min(allLenRatios) max(allLenRatios)];
    ax.XLim = [0, sampleData.Lx];
    ax.YLim = [0, sampleData.Ly];
    % Rescale the axes to mm
    ax.XTick = 0:sampleData.Lx/4:sampleData.Lx;
    ax.YTick = 0:sampleData.Ly/4:sampleData.Ly;
    ax.YTickLabel = ax.YTick/1000;
    ax.XTickLabel = ax.XTick/1000;
    ax.Title.String = sprintf('\\phi = %1.2g; \\Deltaf_D = %1.2g', sampleData.porosity, sampleData.DeltaFd);
end

%% Calculate a histogram of length ratio and find the critical transition
stepT = (max(allLenRatios) - min(allLenRatios))/50;
edgesRatios = min(allLenRatios): stepT: max(allLenRatios);
histoRatios = histcounts(allLenRatios, edgesRatios);

xRatioData = edgesRatios(1:end-1)+stepT/2;
yRatioData = histoRatios;

% Smooth the data to find the changes in slope, which indicate the
% threshold to apply for the removal of edges
smoothedData = smoothdata(yRatioData,'gaussian','SmoothingFactor',0.2,...
    'SamplePoints',xRatioData);

% Find change points
[changeIndices,segmentMean] = ischange(smoothedData,'MaxNumChanges',5,...
    'SamplePoints',xRatioData);

if plotThroatLengthTrans
    % Visualize results
    figure
    plot(xRatioData,yRatioData,'Color',[109 185 226]/255,...
        'DisplayName','Input data')
    hold on
    plot(xRatioData,smoothedData,'Color',[0 114 189]/255,'LineWidth',1.5,...
        'DisplayName','Smoothed data')
    hold off
    legend
    
    % Visualize results
    figure
    plot(xRatioData,smoothedData,'Color',[109 185 226]/255,...
        'DisplayName','Edge length ratio smoothed')
    hold on
    
    % Plot the edges histogram
    bar(edgesRatios(1:end-1)+stepT/2, histoRatios, 'DisplayName', "Histogram data");
    
    % Plot segments between change points
    plot(xRatioData,segmentMean,'Color',[64 64 64]/255,...
        'DisplayName','Segment mean')
    
    % Plot change points
    x = repelem(xRatioData(changeIndices),3);
    y = repmat([ylim(gca) NaN]',nnz(changeIndices),1);
    plot(x,y,'Color',[51 160 44]/255,'LineWidth',1,'DisplayName','Change points')
    title(['Number of change points: ' num2str(nnz(changeIndices))])
    
    hold off
    legend
end

%% Display the ratio values found by the changes in local mean value
xRatioThreshVals = xRatioData(changeIndices);
% Threshold length ratios according to distribution
% % Chose one of the threshold values found before
% switch sum(changeIndices)
%     case 4
%         % For four points of change
%         lRatioThres = xRatioThreshVals(3);
%     case 5
%         % For five points of change
%         lRatioThres = xRatioThreshVals(3);
% end

lRatioThres = xRatioThreshVals(3);

% Extract the edges with the ratio below the threshold
selectInd2 = find(allLenRatios < lRatioThres);
selectedSegments2 = selectedSegments(selectInd2,:);
allLengthsThresh2 = allLengthsThresh(selectInd2);
allLenRatios2 = allLenRatios(selectInd2);
% Collect the list of relevant grains
selectedGrainsDiam2 = allGrainRadThresh(selectInd2,:);

[nSeg2, ~] = size(selectedSegments2);


end
