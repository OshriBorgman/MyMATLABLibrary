function [hOut, diffSqMean] = calculateUnstructuredVariogram(X, Z, binSize)

% CALCULATE UNSTRUCTURED VARIOGRAM Calculate the semi variogram of data in
% unstructured (irregular) positions

% 2021, Oshri Borgman

% INPUT
% X: The position of the points
% Z: The variable values at the points
% binSize: Optional, the bin size in length units

% The binned distances
hOut = [];

% The binned half-averages of the squared differences.
diffSqMean = [];

% The vector of distances between the points
hAll = [];

% The vector of the square differences
diffSq = [];

% calculate for each data point
for i = 1:length(X)
% Create the subset of all other points positions
notXi = X;
notXi(i,:) = [];
% Create the subset of all other points variable values
notZi = Z;
notZi(i) = [];
% The distances between point i and all other points
hAll = [hAll; sqrt((notXi(:,1)-X(i,1)).^2+(notXi(:,2)-X(i,2)).^2)];
% The square of the difference in value at point
diffSq = [diffSq; (Z(i) - notZi).^2];
end

% Bin the data according to distance
[N, edges, bin] = histcounts(hAll);

% If given, use the input bin size
if nargin>2
% Estimate the number of bins
nbins = round((max([X(:,1); X(:,2)]) - min([X(:,1); X(:,2)]))/binSize);
[N, ~, bin] = histcounts(hAll, nbins);
end

% Calculate the mean distance values in the bins
for k = 1:length(N)
diffSqMean(k) = mean(diffSq(bin==k))/2;
end

% Distribute the squared differences according to the bins and calculate
% the half-average
for k = 1:length(N)
hOut(k) = mean(hAll(bin==k))/2;
end

end