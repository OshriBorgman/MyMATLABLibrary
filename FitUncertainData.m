function [a0, a1, varargout] = FitUncertainData(xData, avgVals, uncertainVals, varargin)

% % FIT DATA WITH UNCERTAINTIES Fit data with uncertainties using
% Monte-Carlo simulations to generate random data sets from averages and
% uncertainties. 

% For a uniform distribution, the uncertainties define the range.
% For a normal distribution, the uncertainties define the standard
% deviation

switch length(varargin)
    case 0 
        % Plot
        plotFit = false;
        % The size of the random data set
        kSet = 1000;
        % The type of distribution
        distType = 'uniform';
    case 1
        plotFit = varargin{1};
        kSet = 1000;
        distType = 'uniform';
    case 2
        plotFit = varargin{1};
        kSet = varargin{2};
        distType = 'uniform';
    case 3
        plotFit = varargin{1};
        kSet = varargin{2};
        distType = varargin{3};
end

rndSet = zeros(kSet, length(avgVals));

switch distType
    case 'uniform'
        % Generate a random set of data from the averages and uncertainties
        % from a uniform distribution
        for n = 1:kSet     
            rndSet(n,:) = avgVals-uncertainVals + (2*uncertainVals).*rand(size(avgVals));
        end
    case 'normal'
        % Generate a random set of data from the averages and uncertainties
        % from a normal distribution
        for n = 1:kSet     
            rndSet = uncertainVals.*randn(size(avgVals)) + avgVals;
        end
end
    
% The parameter values of the fitted lines
a0 = [];
a1 = [];

if plotFit
    fh = figure;
    hold on
    varargout = {fh};
end
% Fit each set with a power law
for n = 1:kSet
    if plotFit
        plot(xData, rndSet(n,:), 'd', 'Color', [0.8 0.8 0.8]) 
        [fitRes] = FitPowerLaw(xData, rndSet(n,:), true, figure(fh), [0.5 0.5 0.5]);
    else
        [fitRes] = FitPowerLaw(xData, rndSet(n,:));
    end
    a0(n) = fitRes.Coefficients.Estimate(1);
    a1(n) = fitRes.Coefficients.Estimate(2);
end

end