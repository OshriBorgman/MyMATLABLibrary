function [outputVarSpec, outputVar, ax] = MultiSeriesPlot2(seriesIdx, xVar, yVar, ...
    cmap, legStr, seriesName, propXStr, propYStr, varargin)

%MULTI SERIES PLOT General function to plot several data series

%   Detailed explanation goes here

% Set defaults
logX = false;    
logY = false;
present = false;    
outputIdx = 0;    
marker = 'o';

switch length(varargin)
    case 1 
        logX = varargin{1};    
    case 2
        logX = varargin{1};    
        logy = varargin{2};    
    case 3
        logX = varargin{1};    
        logy = varargin{2};    
        present = varargin{3};
    case 4
        logX = varargin{1};    
        logy = varargin{2};    
        present = varargin{3};
        marker = varargin{4};
    case 5
        logX = varargin{1};    
        logy = varargin{2};    
        present = varargin{3};
        marker = varargin{4};
        outputIdx = varargin{5};
end


figure
hold on
ax = gca;
colInd = 0;

% The output variables we want to calculate from the different series
outputVarSpec = [];
outputVar = {};

for i = 1:length(seriesIdx)
colInd = i;

% variables to plot
xPlot = xVar{seriesIdx(i)};
yPlot = yVar{seriesIdx(i)};

% Save the output variable for all time points
outputVar{i} = yPlot;

plot(xPlot, yPlot, 'o', "Color", cmap(colInd,:), 'MarkerSize', 4, ...
    'MarkerFaceColor', cmap(colInd,:), 'Marker', marker)

leg{colInd} = sprintf('%s = %3.0f', legStr, seriesName(i));
end

ax.XLabel.String = propXStr;
ax.YLabel.String = propYStr;
legend(leg, "Location", "best")
if logX
ax.XScale = "log";
end
if logY
ax.YScale = "log";
end
if present
ax.FontSize = 14;
end

switch outputIdx
    case 1
        % Output the maximum value for each time series
        outputVarSpec(i) = max(yPlot);
    case 2
        % Output the maximum value for each time series
        outputVarSpec(i) = min(yPlot);
    case 3
        % Save the output variable for a specific index
        outputVarSpec(i) = yPlot(outputIdx(i));
end

end

