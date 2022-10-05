function [fh, ax, hp] = histoPlotLog(X, nBins, titlStr, xLabStr, ...
    yLabStr, normPDF, varargin)

% % HISTOPLOTLOG - plot a histogram as a normal plot instead of a bar plot,
% on log-log scale

switch length(varargin)
    case 0
        newFig = true;
        fitModels = false;
    case 1
        newFig = varargin{1};
        fitModels = false;
    case 2
        newFig = varargin{1};
        fitModels = varargin{2};
end
    
switch normPDF
    case false
        [N,edges] = histcounts(log(X), nBins);
    case true
        [N,edges] = histcounts(log(X), nBins, 'Normalization', 'pdf');
end

if newFig
fh = figure;
end

ax = gca;
hp = plot(exp(edges(1:end-1)+(edges(2:end)-edges(1:end-1))/2), N, 'o', ...
    'LineWidth', 2, 'MarkerSize', 8);
ax.Title.String = titlStr;
ax.XLabel.String = xLabStr;
ax.YLabel.String = yLabStr;
ax.XScale = 'log';
ax.YScale = 'log';

if fitModels
% [] = FitLinModelToData;

end

end