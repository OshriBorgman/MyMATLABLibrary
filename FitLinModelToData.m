function [outputArg1,outputArg2] = FitLinModelToData(inputArg1,inputArg2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
xPlot = log(XData(YData~=0));
yPlot = log(nonzeros(YData));

% Find change points
[changeIndices,segmentSlope,segmentIntercept] = ischange(yPlot,'linear',...
    'SamplePoints',xPlot);

% Visualize results
hold on
% Plot segments between change points
plot(exp(xPlot),exp(segmentSlope(:).*xPlot(:)+segmentIntercept(:)),...
    'Color',[64 64 64]/255,'DisplayName','Linear regime')
% Plot change points
x = repelem(xPlot(changeIndices),3);
y = repmat([ylim(gca) NaN]',nnz(changeIndices),1);
plot(exp(x), y,'Color',[51 160 44]/255,'LineWidth',1,'DisplayName','Change points')
title(['Number of change points: ' num2str(nnz(changeIndices))])
hold off
legend
clear segmentSlope segmentIntercept x y

% find the values of the moment from the linear section related to
% stationary dispersion regime
changeIndicesFound = find(changeIndices);
for i = 1:length(changeIndicesFound)+1
if i==1
linearVelVals = yPlot(1:changeIndicesFound(i));
linearVelValsX = xPlot(1:changeIndicesFound(i));
elseif i==length(changeIndicesFound)+1
linearVelVals = yPlot(changeIndicesFound(i-1):end);
linearVelValsX = xPlot(changeIndicesFound(i-1):end);
else
linearVelVals = yPlot(changeIndicesFound(i-1):changeIndicesFound(i));
linearVelValsX = xPlot(changeIndicesFound(i-1):changeIndicesFound(i));
% Fit a linear model:
end
linModel{i} = fitlm(linearVelValsX, linearVelVals);
end
end

