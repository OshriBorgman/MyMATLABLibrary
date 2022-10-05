function [dataStruct] = CalculateSampleGeometryMultiple(dataStruct, plotThLenHist, ...
    calcVario, plotVario, fitVario, plotPerm)

% CALCULATE SAMPLE GEOMETRY FOR MULTIPLE SAMPLES Calculate different features of the sample
% geometry, based on a 2-D array of circles, for a set of multiple samples.

% The sample index
% parfor nSample = 1:length(SimDataSave)
for nSample = 1:length(dataStruct)

Xg = dataStruct(nSample).XGrains;
Dg = dataStruct(nSample).DGrains;
meanDiameter = mean(Dg);
Lx = dataStruct(nSample).Lx;
Ly = dataStruct(nSample).Ly;

% Calculate the grain diameter histogram
stepD = (max(Dg) - min(Dg))/25;
edgesD = min(Dg):stepD:max(Dg);
histoD = histcounts(Dg,edgesD);

% NO NEED TO rescale the sizes from cm to um
dataStruct(nSample).StepD = stepD;%*1e4;
dataStruct(nSample).EdgesD = edgesD;%*1e4;
dataStruct(nSample).HistoD = histoD;
% Create the Delaunay triangulation and obtain throat sizes
[selectedSegments2, allLengthsThresh2, selectedGrainsDiam2, nSeg2, ~] = ...
CalculateThroatApertures2D(Xg, Dg, 0, 0, 0);

% % Calculate the spatial correlation of throat sizes
% Find the position of the edges of the throats (grain centers)
x1 = selectedSegments2(:, 1);
y1 = selectedSegments2(:, 2);
x2 = selectedSegments2(:, 3);
y2 = selectedSegments2(:, 4);

% Update the histogram of throats
stepT = (max(allLengthsThresh2) - min(allLengthsThresh2))/25;
edgesT2 = min(allLengthsThresh2): stepT: max(allLengthsThresh2);
histoT2 = histcounts(allLengthsThresh2, edgesT2);

% Save the data and rescale to present in units of mum NO NEED
dataStruct(nSample).StepT = stepT;%*1e4;
dataStruct(nSample).EdgesT = edgesT2;%*1e4;
dataStruct(nSample).HistoT = histoT2;

% % The overall throat size range
% throatSizeRange = [0 0.8];
% % The maximum grain size
% throatSizeMax = 0.8;
% 
% % Plot the absolute throat sizes
% PlotThroatSizes(throatSizeRange, throatSizeMax, Dg, Xg, ...
%     allLengthsThresh2, selectedSegments2, Lx, Ly, ...
%     dataStruct(nSample).porosity, dataStruct(nSample).DeltaFd)
% 
% % Plot the throat sizes relative to the mean
% throatSizeRel = allLengthsThresh2./mean(allLengthsThresh2);
% throatSizeRelRange = [min(throatSizeRel) max(throatSizeRel)];
% throatSizeMax = max(throatSizeRel);
% PlotThroatSizes(throatSizeRelRange, throatSizeMax, Dg, Xg, ...
%     throatSizeRel, selectedSegments2, Lx, Ly, ...
%     dataStruct(nSample).porosity, dataStruct(nSample).DeltaFd)

% % Calculate the relative permeability
% according to Eq. 37 in Sobera and Kleijn PRE 2006 (https://link.aps.org/doi/10.1103/PhysRevE.74.036301):

[k, kRel] = SoberaKleijnRelPerm(allLengthsThresh2, Dg);

% Save the results
dataStruct(nSample).throatHalfLength = allLengthsThresh2/2;
dataStruct(nSample).throatSegments = selectedSegments2;
dataStruct(nSample).permeablAbs = k;
dataStruct(nSample).permeablRel = kRel;

end

% % Plot the modified histogram of edgge lengths
if plotThLenHist
for n = 1:length(dataStruct)
    figure
    bar(dataStruct(n).EdgesT(1:end-1)+dataStruct(n).StepT/2, dataStruct(n).HistoT);
    xlabel('Length [mm]')
    ylabel('Number')
    title(sprintf('Filtered throat lengths: $\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
        dataStruct(n).porosity, dataStruct(n).DeltaFd, dataStruct(n).lambda));
end
% Plot in one figure
figure
hold on
for n = 1:length(dataStruct)
    histogram(dataStruct(n).throatHalfLength.*2, 'BinWidth', dataStruct(n).MeshLen/50, ...
        "displayname", sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
        dataStruct(n).porosity, dataStruct(n).DeltaFd, dataStruct(n).lambda), 'FaceAlpha', 0.5)
%     bar(SimDataSave(n).EdgesT(1:end-1)+SimDataSave(n).StepT/2, SimDataSave(n).HistoT, "displayname", ...
%         sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
%         SimDataSave(n).porosity, SimDataSave(n).DeltaFd, SimDataSave(n).lambda), 'FaceAlpha', 0.5);
end
xlabel('Length [mm]')
ylabel('Number')
title('Filtered throat lengths')
legend('show')
end

% % Calculate the semi-variogram of the data
if calcVario
% Calculate the position of the throat centers
[xThr, yThr] = calculateThroatCenters(x1, y1, x2, y2, selectedGrainsDiam2);

% Calculate the semi-variogram of the throat sizes
[hOut, gammaH] = calculateUnstructuredVariogram([xThr, yThr], allLengthsThresh2, 0.1);
dataStruct(nSample).HOut = hOut;
dataStruct(nSample).gammaH = gammaH;
end

% % Plot the semi-variogram
if plotVario
figure
hold on
for n = 1:length(dataStruct)
% Plot the seal which is the variance of the throat sizes
plot([0 max(dataStruct(n).HOut)], [var(dataStruct(n).throatHalfLength*2) var(dataStruct(n).throatHalfLength*2)], ...
    '--', "DisplayName", sprintf('$\\sigma^2(r)$: $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    dataStruct(n).DeltaFd, dataStruct(n).lambda))
% Plot the semi-variogram data
plot(dataStruct(n).HOut, dataStruct(n).gammaH, 'o', "DisplayName", ...
    sprintf('$\\gamma(h)$: $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    dataStruct(n).DeltaFd, dataStruct(n).lambda))
end
title('Throat constrictions semi-variogram')
xlabel('Distance [mm]')
ylabel('$\gamma(h)$ [mm$^2$]')
legend('show')
end

% % Fit the semi-variograms
if fitVario
%  Create a fit with a spherical variogram model
%      X Input : xdata
%      Y Output: ydata

for n = 1:length(dataStruct)

xdata = dataStruct(n).HOut;    
ydata = dataStruct(n).gammaH;

% The spherical model is defined for h<lambda, so limit the data set to
% x<lambda
endIdx = find(xdata > dataStruct(n).lambda*dataStruct(n).MeshLen, 1, 'first');
xdata = xdata(1:endIdx+10);
ydata = ydata(1:endIdx+10);

[xData, yData] = prepareCurveData( xdata, ydata );

% Set up fittype and options.
ft = fittype( 'a + b/2*((3*x/c)-(x/c)^3)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.278033267725261 0.418908690774951 0.860101210049283];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData);
legend( h, 'ydata vs. xdata', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'xdata', 'Interpreter', 'none' );
ylabel( 'ydata', 'Interpreter', 'none' );
grid on
end
end

% % Plot the permeabilities
if plotPerm
figure
plot([dataStruct.DeltaFd], [dataStruct.permeablAbs], 's')
xlabel('$\Delta f_D$')
ylabel('$k$ [mm$^2$]')
title('Absolute permeability')
figure
plot([dataStruct.lambda], [dataStruct.permeablAbs], 's')
xlabel('$\lambda$')
ylabel('$k$ [mm$^2$]')
title('Absolute permeability')
end