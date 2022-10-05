function [fh] = PlotWithErrorPatch(xVar, yVar, err, ...
    legStr, legPropStr, propXStr, propYStr, varargin)
%PLOT DATA WITH ERRORS AS PATCH General function to plot data with errors
%indicated as patches

%   Detailed explanation goes here

switch length(varargin)
    case 0
        logX = false;
        logY = false;
        present = false;
        faceCol =  [1 0  0];
        edgeCol = [1 0 0];
        patchColor = [0.7 0.7 0.7];
        newFig = true;
    case 1
        present = varargin{1};
        logX = false;
        logY = false;
        faceCol =  [1 0  0];
        edgeCol = [1 0 0];
        patchColor = [0.7 0.7 0.7];
        newFig = true;
    case 2
        present = varargin{1};
        logX = varargin{2};
        logY = false;
        faceCol =  [1 0  0];
        edgeCol = [1 0 0];
        patchColor = [0.7 0.7 0.7];
        newFig = true;
    case 3
        present = varargin{1};
        logX = varargin{2};
        logY = varargin{3};
        faceCol =  [1 0  0];
        edgeCol = [1 0 0];
        patchColor = [0.7 0.7 0.7];
        newFig = true;
    case 4
        present = varargin{1};
        logX = varargin{2};
        logY = varargin{3};
        faceCol =  varargin{4};
        edgeCol = [1 0 0];
        patchColor = [0.7 0.7 0.7];
        newFig = true;
    case 5
        present = varargin{1};
        logX = varargin{2};
        logY = varargin{3};
        faceCol =  varargin{4};
        edgeCol = varargin{5};
        patchColor = [0.7 0.7 0.7];
        newFig = true;
    case 6
        present = varargin{1};
        logX = varargin{2};
        logY = varargin{3};
        faceCol =  varargin{4};
        edgeCol = varargin{5};
        patchColor = varargin{6};
        newFig = true;
    case 7
        present = varargin{1};
        logX = varargin{2};
        logY = varargin{3};
        faceCol =  varargin{4};
        edgeCol = varargin{5};
        patchColor = varargin{6};
        newFig = varargin{7};
end

if newFig
    fh = figure;
    hold on
    ax = gca;
end

xPlot = xVar;
yPlot = yVar;

hPlot = plot(xPlot, yPlot, '.', "LineWidth", 2, ...
    "DisplayName", sprintf('$%s$', legStr));
hPlot.MarkerFaceColor = faceCol;
hPlot.MarkerEdgeColor = edgeCol;

xPatch = [xPlot, fliplr(xPlot)];
yPatch = [yPlot+err, fliplr(yPlot-err)];
hPatch = patch(xPatch, yPatch, 1, 'FaceColor', patchColor, 'EdgeColor',...
    'none','FaceAlpha',.5);
hPatch.Annotation.LegendInformation.IconDisplayStyle = 'off';

ax.XLabel.String = propXStr;
ax.YLabel.String = propYStr;
legend("show","Location","best")
if logX
    ax.XScale = "log";
end
if logY
    ax.YScale = "log";
end
if present
    ax.FontSize = 14;
end

end

