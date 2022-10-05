function [dataStruct] = AnalyzePoreSizeFun(dataStruct, plotFlag)

for nSample = 1:length(dataStruct)
    
d = dataStruct(nSample).DGrains;
X = dataStruct(nSample).XGrains;
throatNum = length(dataStruct(nSample).throatHalfLength);
throatEndpoints = dataStruct(nSample).throatSegments;
imgLength = [max(X(:,1))-min(X(:,1)) max(X(:,2))-min(X(:,2))];

% Create the image of edges to isolate the pores
f = figure('Visible', 'on');
hold on

% Plot the grains
for p = 1:length(d)
rectangle('Position',[X(p,1)-d(p)/2 X(p,2)-d(p)/2 ...
    d(p) d(p)], 'Curvature', [1 1], "FaceColor", 'k')
end

% Plot the throats
for ii=1:throatNum
    plot(throatEndpoints(ii, [1 3]), throatEndpoints(ii, [2 4]), 'r-', 'LineWidth', 1.5)
end

axis equal tight
ax = f.Children;
ax.YAxis.Visible = "off";
ax.XAxis.Visible = "off";
f.Units = 'normalized';
f.Position = [0 0 2 2];
ax.Units = 'normalized';
f.Position = [0 0 2 2];
fr = getframe(f.Children);
% get the image data
imData = rgb2gray(fr.cdata);
% Find the pores by binarizing and labeling the pores
poreClust = bwconncomp((imbinarize(imData)), 4); 
poreclust_idmap = labelmatrix(poreClust);

if plotFlag
%     Plot the pore map
    figure
    clf
    cmap = colormap(jet(2^16));
    [a, b] = size(cmap);
    c_vec = randperm(a);
    cmap2 = cmap(c_vec,:);
    cmap2(1,:) = [0 0 0];
    imagesc(poreclust_idmap)
    axis equal tight
    colormap(cmap2);

    figure
    histogram(SimDataSave(1).throatHalfLength*2, 40, 'Normalization', 'pdf')
    title('pore throat lengths')
    xlabel('length [mm]')
    ylabel('pdf')
    
end

% Rescale to obtain size in mm:
xScale = dataStruct(nSample).Lx/size(fr.cdata,2);
yScale = dataStruct(nSample).Ly/size(fr.cdata,1);
avgScale = mean([xScale, yScale]);

% Collect the properties of the pore sizes 
poreStats = regionprops(poreClust,'Area','EquivDiameter','Centroid',"BoundingBox","Circularity");
% Remove wrongly identified pores, or those outside the network
poreStats(isinf([poreStats.Circularity])) = [];
poreStats([poreStats.Circularity]<0.1) = [];
poreStats([poreStats.Area]==1) = [];
poreStats([poreStats.Area]>1000) = [];
allPoreAreas = cat(1, [poreStats.Area].*avgScale^2);
allPoreDiameters = cat(1, [poreStats.EquivDiameter].*avgScale);

if plotFlag
figure
histogram(allPoreDiameters, 40, 'Normalization', 'pdf')
title('pore diameters')
xlabel('diameter [mm]')
ylabel('pdf')
end

dataStruct(nSample).PoreAreas = allPoreAreas;
dataStruct(nSample).PoreDiameters = allPoreDiameters;

end

end