% % Analyze all samples
%% Collect the analysis for all heterogenous samples
clear AnalysisDataSave

% The sample index
% parfor nSample = 1:length(SimDataSave)
for nSample = 1:length(SimDataSave)

Xg = SimDataSave(nSample).XGrains;
Dg = SimDataSave(nSample).DGrains;
meanDiameter = mean(Dg);
Lx = SimDataSave(nSample).Lx;
Ly = SimDataSave(nSample).Ly;

% Calculate the grain diameter histogram
stepD = (max(Dg) - min(Dg))/25;
edgesD = min(Dg):stepD:max(Dg);
histoD = histcounts(Dg,edgesD);

% NO NEED TO rescale the sizes from cm to um
SimDataSave(nSample).StepD = stepD;%*1e4;
SimDataSave(nSample).EdgesD = edgesD;%*1e4;
SimDataSave(nSample).HistoD = histoD;
% Create the Delaunay triangulation and obtain throat sizes
[selectedSegments2, allLengthsThresh2, selectedGrainsDiam2, nSeg2] = ...
CalculateThroatApertures2D(Xg, Dg, 0, 0, 0);

%% Calculate the spatial correlation of throat sizes
% Find the position of the edges of the throats (grain centers)
x1 = selectedSegments2(:, 1);
y1 = selectedSegments2(:, 2);
x2 = selectedSegments2(:, 3);
y2 = selectedSegments2(:, 4);

% Calculate the position of the throat centers
[xThr, yThr] = calculateThroatCenters(x1, y1, x2, y2, selectedGrainsDiam2);

% Calculate the semi-variogram of the throat sizes
[hOut, gammaH] = calculateUnstructuredVariogram([xThr, yThr], allLengthsThresh2, 0.01);

SimDataSave(nSample).HOut = hOut;
SimDataSave(nSample).gammaH = gammaH;

% Update the histogram of throats
stepT = (max(allLengthsThresh2) - min(allLengthsThresh2))/25;
edgesT2 = min(allLengthsThresh2): stepT: max(allLengthsThresh2);
histoT2 = histcounts(allLengthsThresh2, edgesT2);

% Save the data and rescale to present in units of mum NO NEED
SimDataSave(nSample).StepT = stepT;%*1e4;
SimDataSave(nSample).EdgesT = edgesT2;%*1e4;
SimDataSave(nSample).HistoT = histoT2;

%% Calculate the relative permeability
% according to Eq. 37 in Sobera and Kleijn PRE 2006 (https://link.aps.org/doi/10.1103/PhysRevE.74.036301):

[k, kRel] = SoberaKleijnRelPerm(allLengthsThresh2, Dg);

% Save the results
SimDataSave(nSample).throatHalfLength = allLengthsThresh2/2;
SimDataSave(nSample).permeablAbs = k;
SimDataSave(nSample).permeablRel = kRel;

end

%% Plot the modified histogram of edgge lengths

for n = 1:length(SimDataSave)
figure
bar(SimDataSave(n).EdgesT(1:end-1)+SimDataSave(n).StepT/2, SimDataSave(n).HistoT);
xlabel('Length [m]')
ylabel('Number')
title(sprintf('Filtered throat lengths: $\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    SimDataSave(n).porosity, SimDataSave(n).DeltaFd, SimDataSave(n).lambda));
end
% Plot in one figure
figure
hold on
for n = 1:length(SimDataSave)
bar(SimDataSave(n).EdgesT(1:end-1)+SimDataSave(n).StepT/2, SimDataSave(n).HistoT, "displayname", ...
    sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    SimDataSave(n).porosity, SimDataSave(n).DeltaFd, SimDataSave(n).lambda), 'FaceAlpha', 0.5);
end
xlabel('Length [m]')
ylabel('Number')
title('Filtered throat lengths')
legend('show')

%% Plot the semi-variogram
figure
hold on
for n = 1:length(SimDataSave)
% Plot the seal which is the variance of the throat sizes
plot([0 max(SimDataSave(n).HOut)], [var(SimDataSave(n).throatHalfLength*2) var(SimDataSave(n).throatHalfLength*2)], ...
    '--', "DisplayName", sprintf('$\\sigma^2(r)$: $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    SimDataSave(n).DeltaFd, SimDataSave(n).lambda))
% Plot the semi-variogram data
plot(SimDataSave(n).HOut, SimDataSave(n).gammaH, 'o', "DisplayName", ...
    sprintf('$\\gamma(h)$: $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    SimDataSave(n).DeltaFd, SimDataSave(n).lambda))
end
title('Throat constrictions semi-variogram')
xlabel('Distance [m]')
ylabel('$\gamma(h)$ [m$^2$]')
legend('show')


%% Fit the semi-variograms

%  Create a fit with a spherical variogram model

%      X Input : xdata
%      Y Output: ydata

for n = 1:length(SimDataSave)

xdata = SimDataSave(n).HOut;    
ydata = SimDataSave(n).gammaH;

% The spherical model is defined for h<lambda, so limit the data set to
% x<lambda
endIdx = find(xdata > SimDataSave(n).lambda*SimDataSave(n).MeshLen, 1, 'first');
xdata = xdata(1:endIdx+10);
ydata = ydata(1:endIdx+10);

[xData, yData] = prepareCurveData( xdata, ydata );

% Set up fittype and options.
ft = fittype( 'a + b/2*((3*x/c)-(x/c)^3)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.278033267725261 0.418908690774951 0.860101210049283];

% % Fit model to data.
% [fitresult, gof] = fit( xData, yData, ft, opts );
% 
% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData);
% legend( h, 'ydata vs. xdata', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'xdata', 'Interpreter', 'none' );
ylabel( 'ydata', 'Interpreter', 'none' );
grid on
end

%% Plot the permeabilities
figure
plot([SimDataSave.DeltaFd], [SimDataSave.permeablAbs], 's')
xlabel('$\Delta f_D$')
ylabel('$k$ [m$^2$]')
title('Absolute permeability')
figure
plot([SimDataSave.lambda], [SimDataSave.permeablAbs], 's')
xlabel('$\lambda$')
ylabel('$k$ [mm$^2$]')
title('Absolute permeability')