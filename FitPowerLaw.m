function [linModel, varargout] = FitPowerLaw(xData, yData, varargin)

% % FIT POWER LAW TO DATA Taking a data set, and fitting a linear function
% to its log-transformed values, with an option to add the fitting to a plot

switch length(varargin)
    case 0
        plotFit = false;
    case 1
        plotFit = varargin{1};
        figHand = figure;
        plotColor = 'k';
        plotStyle = '--';
        plotWidth = 1;
        legPropStr = 'x';
    case 2
        plotFit = varargin{1};
        figHand = varargin{2};
        plotColor = 'k';
        plotStyle = '--';
        plotWidth = 1;
        legPropStr = 'x';
    case 3
        plotFit = varargin{1};
        figHand = varargin{2};
        plotColor = varargin{3};
        plotStyle = '--';
        plotWidth = 1;
        legPropStr = 'x';
    case 4
        plotFit = varargin{1};
        figHand = varargin{2};
        plotColor = varargin{3};
        plotStyle = varargin{4};
        plotWidth = 1;
        legPropStr = 'x';
    case 5
        plotFit = varargin{1};
        figHand = varargin{2};
        plotColor = varargin{3};
        plotStyle = varargin{4};
        plotWidth = varargin{5};
        legPropStr = 'x';
    case 6
        plotFit = varargin{1};
        figHand = varargin{2};
        plotColor = varargin{3};
        plotStyle = varargin{4};
        plotWidth = varargin{5};
        legPropStr = varargin{6};
end        

% Fit a log-log scaling:
linModel = fitlm(log(xData), log(yData));
xPredict = linspace(min(xData), max(xData), 100)';

if plotFit
    figure(figHand)
    varargout{1} = plot(xPredict, exp(predict(linModel, log(xPredict))), ...
        'Color', plotColor, "LineStyle", plotStyle, 'LineWidth', plotWidth,...
        "DisplayName", sprintf('$%s ^{%3.2f \\pm %3.2f}$', legPropStr,...
        linModel.Coefficients.Estimate(2), linModel.Coefficients.SE(2)));
end

end