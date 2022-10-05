function [predict, pMinFit] = LeastSqFitWithYError(xi, yi, deli, pMin, pMax)

% % EXAMPLE
% % The vector of independent variables
% xi = linspace(10, 50, 10);
% % the vector of errors in y
% deli = 0.1*rand(1,10);
% % The vector of response values
% yi = 10+2*xi+deli;
% % The minimum parameter estimates
% pMin = [0 0.1];
% % The maximum parameter estimates
% pMax = [20 5];


% The prediction function
predict = @(x,p) p(1)*x.^p(2);
% The number of parameter sets
nPSets = 1e6;
% The matrix of parameter values
p = [pMin(1) + (pMax(1)-pMin(1))*rand(nPSets,1) pMin(2) + (pMax(2)-pMin(2))*rand(nPSets,1)];
% Run the Monte Carlo simulation
for i = 1:nPSets
    chi2(i) = sum((yi-predict(xi,p(i,:))).^2./deli.^2);
end
% Find the index and the minimum parameters
[M I] = min(chi2);
pMinFit = p(I,:)

figure;
hold on
errorbar(xi,yi,deli,'s','MarkerSize',10,...
    'MarkerEdgeColor','red','MarkerFaceColor','red')
plot(xi, predict(xi, p(I,:)), '--k')
set(gca, 'XScale', 'log', 'YScale', 'log')

end