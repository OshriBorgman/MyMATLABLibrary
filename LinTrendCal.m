function [x_plot, y_plot, slope, intrcpt] = LinTrendCal(x_in, y_in)
%LINEAR TREND CALCULATION Calculation of a linear trendline from a given
%curve

% Take x and y vectors and fit a linear curve to find the slope and
% intercept. Find the most significant linear part of the curve and fit the
% function to it.

% INPUT
% x_in: the input x vector
% y_in: the input y vector

% OUTPUT
% x_plot: the part of the input x-vector fitted with a linear trend
% y_plot: the part of the input y-vector fitted with a linear trend
% slope: the slope of the linear trend
% intrcpt: the intercept of the linear trend

% Find linear trends in the data
chngePnts = ischange(y_in, 'linear', 'MaxNumChanges', 2);
% Add a change point at the beginning and at the end
chngePnts([1 end]) = true;
chngePntsIdx = find(chngePnts);
% If there are no change points the entire range is on one linear curve
if ~any(chngePnts)
x_plot = x_in;
y_plot = y_in;
% If there are change points, find the segment with the largest number of
% points
else
[xi, i] = max(diff(chngePntsIdx));
xi_start = double(chngePntsIdx(i));
xi_end = chngePntsIdx(i)+xi-1;
% Collect the values of the selected range
x_plot = x_in(xi_start:xi_end);
y_plot = y_in(xi_start:xi_end);
end

% Fit the linear model
linVelModel = fitlm(x_plot, y_plot);
% The fitted parameters
slope = linVelModel.Coefficients.Estimate(2);
intrcpt = linVelModel.Coefficients.Estimate(1);

end