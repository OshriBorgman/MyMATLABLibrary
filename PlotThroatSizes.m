function [] = PlotThroatSizes(sizeRange, sizeMax, Dg, Xg, ...
    allLengths, segments, Lx, Ly, porosity, DeltaFd)

% PLOT THROAT SIZES Plot a map of throat sizes from the data.

% Use a colormap for the grains according to their size
cMapGrainSize = hot(256);

figure
clf
ax = gca;
% cmap = colormap(hot(nSeg*10));
% cmapLims = [min(cmap); max(cmap)];
axis equal
hold on
% Plot the grains
for p = 1:length(Dg)
rectangle('Position',[Xg(p,1)-Dg(p)/2 Xg(p,2)-Dg(p)/2 Dg(p) Dg(p)], 'Curvature', [1 1], ...
    "FaceColor", [0.5 0.5 0.5], "EdgeColor", 'none')
end
% Plot the throats. 
for s = 1:length(allLengths)
% Define the color of the throat according to the its length
%     colEdge = round(interp1([min(allLenRatios); max(allLenRatios)], [1 length(cmap)], ...
%         allLenRatiosSort(s)));
    plot(segments(s,[1 3]), segments(s,[2 4]), "Color", ...
        cMapGrainSize(min(round((allLengths(s)-sizeRange(1))./(sizeRange(2)-sizeRange(1))*255), 255)+1,:), ...
        "LineWidth", 2)    
%         cmap(colEdge,:), "LineWidth", 1)
end
caxis([min(allLengths) max(allLengths)])
colormap(hot)
c = colorbar;
axis equal tight
% c.TickLabels = [min(allLenRatios) max(allLenRatios)];
ax.XLim = [0, Lx];
ax.YLim = [0, Ly];
% Rescale the axes to mm
ax.XTick = 0:Lx/4:Lx;
ax.YTick = 0:Ly/4:Ly;
ax.YTickLabel = ax.YTick/1000;
ax.XTickLabel = ax.XTick/1000;
ax.Title.String = sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g', ...
    porosity, DeltaFd);

end