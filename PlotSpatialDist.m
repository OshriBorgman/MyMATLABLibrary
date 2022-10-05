function [] = PlotSpatialDist(coord, col, titlStr, cBarStr)

%PLOT SPATIAL DISTRIBUTION Plot spatial distribution of data
%   Plot spatial distribution of data points with colors to indicate a
%   quantity

% INPUT
% coord - coordinates of the plotted points
% col - the color indicator
% titlStr - the title string
% cBarStr - the colorbar title string

figure;
scatter(coord(1:2:end-1), coord(2:2:end), [], col, "filled")
title(titlStr)
xlabel('x-coordinate')
ylabel('y-coordinate')
cBar = colorbar;
colormap('winter')
cBar.Label.String = cBarStr;
cBar.Label.Interpreter= "latex";
axis equal tight

end

