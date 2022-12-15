function [fh] = PlotFieldImage2(X, titleStr, fighand, xStr, yStr, axLim)

% PLOT FIELD IMAGE Use the imagesc function to plot an image of variable
% fields

% INPUT
% X: the variable field to plot
% titleStr: the plot title string, a string
% fighand: figure handle, if doesn't exist open a new image
% xStr: the x-axis label, a string
% yStr: the y-axis label, a string
% axLim: the axes limits, a set of 4 double values

if nargin>2
    fh = fighand;
else
    fh = figure;
end

imagesc(X)
axis equal tight
% Add title if needed
if nargin>1
title(titleStr)
end
% Add x-axis label if needed
if nargin>3
xlabel(xStr)
end
% Add y-axis label if needed
if nargin>4
ylabel(yStr)
end
% Limit axes if needed
if nargin>5
xlim([axLim{1,1}, axLim{1,2}])
ylim([axLim{2,1}, axLim{2,2}])
end

end

