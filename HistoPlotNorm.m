function [fh, ax, hp, linModel] = HistoPlotNorm(X, nBins, titlStr, xLabStr, ...
    yLabStr, varargin)

% % HISTOPLOTNORM - plot a histogram as a normal plot instead of a bar plot

switch length(varargin)
    case 0
        newFig = true;
        loglog = false;
        fitModels = false;
    case 1
        newFig = varargin{1};
        loglog = false;
        fitModels = false;
    case 2
        newFig = varargin{1};
        loglog = varargin{2};
        fitModels = false;
    case 3
        newFig = varargin{1};
        loglog = varargin{2};
        fitModels = varargin{3};
end
    
if loglog
    edgeLog = logspace(log10(min(nonzeros(X))), ...
            log10(max(nonzeros(X))), round(length(X)/10));
    [N,edges] = histcounts(X, edgeLog);
else
    [N,edges] = histcounts(X, nBins);
end

if newFig
    fh = figure;
end

ax = gca;
hp = plot(edges(1:end-1)+(edges(2:end)-edges(1:end-1))/2, N, 'o', ...
    'LineWidth', 2, 'MarkerSize', 8);
ax.Title.String = titlStr;
ax.XLabel.String = xLabStr;
ax.YLabel.String = yLabStr;
if loglog
    ax.XScale = 'log';
    ax.YScale = 'log';
end

if fitModels
    
else
    linModel = [];
end

end