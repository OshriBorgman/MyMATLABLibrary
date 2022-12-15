function [x_plot, y_plot, slope, intrcpt] = LinVelCal(x_in, y_in)
%LINEAR VELOCITY CALCULATION Calculation of linear velocity from a set of
% positions  

% Use a set of position points and their respective time and fit a linear
% curve to find the velocity. Find the most significant linear part of the
% curve and fit the function to it.

% INPUT
% x_in: the input time vector
% y_in: the input value vector

% OUTPUT
% x_plot: the part of the input x-vector fitted with a linear trend
% y_plot: the part of the input y-vector fitted with a linear trend
% slope: the slope of the linear trend
% intrcpt: the intercept of the linear trend

% Find linear trends in the data
chngePnts = ischange(y_in, 'linear');
% Add a change point at the beginning and at the end
chngePnts([1 end]) = true;
% If there are no change points the entire range is on one linear curve
if ~any(chngePnts)
x_plot = x_in;
y_plot = y_in;
% If there are change points, find the segment with the largest number of
% points
else
[xi, i] = max(diff(find(chngePnts)));
xi_start = double(chngePnts(i));
xi_end = chngePnts(i)+xi-1;
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