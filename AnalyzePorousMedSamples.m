function [DataStructOut] = AnalyzePorousMedSamples(DataStructIn, plotFlag)

% % Collect the analysis for all heterogenous samples

DataStructOut = DataStructIn;

% The sample index
% parfor nSample = 1:length(SimDataSave)
for nSample = 1:length(DataStructIn)

Xg = DataStructIn(nSample).XGrains;
Dg = DataStructIn(nSample).DGrains;
meanDiameter = mean(Dg);
Lx = DataStructIn(nSample).Lx;
Ly = DataStructIn(nSample).Ly;

% Calculate the grain diameter histogram
stepD = (max(Dg) - min(Dg))/25;
edgesD = min(Dg):stepD:max(Dg);
histoD = histcounts(Dg,edgesD);

% NO NEED TO rescale the sizes from cm to um
DataStructOut(nSample).StepD = stepD;%*1e4;
DataStructOut(nSample).EdgesD = edgesD;%*1e4;
DataStructOut(nSample).HistoD = histoD;
% Create the Delaunay triangulation and obtain throat sizes
[selectedSegments2, allLengthsThresh2, selectedGrainsDiam2, nSeg2] = ...
CalculateThroatApertures2D(Xg, Dg, 0, 0, 0);

% % Calculate the spatial correlation of throat sizes
% Find the position of the edges of the throats (grain centers)
x1 = selectedSegments2(:, 1);
y1 = selectedSegments2(:, 2);
x2 = selectedSegments2(:, 3);
y2 = selectedSegments2(:, 4);

% Calculate the position of the throat centers
[xThr, yThr] = calculateThroatCenters(x1, y1, x2, y2, selectedGrainsDiam2);

% Calculate the semi-variogram of the throat sizes
[hOut, gammaH] = calculateUnstructuredVariogram([xThr, yThr], allLengthsThresh2);%, 0.01);

DataStructOut(nSample).HOut = hOut;
DataStructOut(nSample).gammaH = gammaH;

% Update the histogram of throats
stepT = (max(allLengthsThresh2) - min(allLengthsThresh2))/25;
edgesT2 = min(allLengthsThresh2): stepT: max(allLengthsThresh2);
histoT2 = histcounts(allLengthsThresh2, edgesT2);

% Save the data and rescale to present in units of mum NO NEED
DataStructOut(nSample).StepT = stepT;%*1e4;
DataStructOut(nSample).EdgesT = edgesT2;%*1e4;
DataStructOut(nSample).HistoT = histoT2;

% % Calculate the relative permeability
% according to Eq. 37 in Sobera and Kleijn PRE 2006 (https://link.aps.org/doi/10.1103/PhysRevE.74.036301):

[k, kRel] = SoberaKleijnRelPerm(allLengthsThresh2, Dg);

% Save the results
DataStructOut(nSample).throatHalfLength = allLengthsThresh2/2;
DataStructOut(nSample).permeablAbs = k;
DataStructOut(nSample).permeablRel = kRel;

end

if plotFlag
% % Plot the modified histogram of edgge lengths

for n = 1:length(DataStructOut)
figure
bar(DataStructOut(n).EdgesT(1:end-1)+DataStructOut(n).StepT/2, DataStructOut(n).HistoT);
xlabel('Length [m]')
ylabel('Number')
title(sprintf('Filtered throat lengths: $\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    DataStructOut(n).porosity, DataStructOut(n).DeltaFd, DataStructOut(n).lambda));
end
% Plot in one figure
figure
hold on
for n = 1:length(DataStructOut)
bar(DataStructOut(n).EdgesT(1:end-1)+DataStructOut(n).StepT/2, DataStructOut(n).HistoT, "displayname", ...
    sprintf('$\\phi$ = %1.2g; $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    DataStructOut(n).porosity, DataStructOut(n).DeltaFd, DataStructOut(n).lambda), 'FaceAlpha', 0.5);
end
xlabel('Length [m]')
ylabel('Number')
title('Filtered throat lengths')
legend('show')

% % Plot the semi-variogram
figure
hold on
for n = 1:length(DataStructOut)
% Plot the seal which is the variance of the throat sizes
plot([0 max(DataStructOut(n).HOut)], [var(DataStructOut(n).throatHalfLength*2) var(DataStructOut(n).throatHalfLength*2)], ...
    '--', "DisplayName", sprintf('$\\sigma^2(r)$: $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    DataStructOut(n).DeltaFd, DataStructOut(n).lambda))
% Plot the semi-variogram data
plot(DataStructOut(n).HOut, DataStructOut(n).gammaH, 'o', "DisplayName", ...
    sprintf('$\\gamma(h)$: $\\Delta f_D$ = %1.2g; $\\lambda = $%1.3g', ...
    DataStructOut(n).DeltaFd, DataStructOut(n).lambda))
end
title('Throat constrictions semi-variogram')
xlabel('Distance [m]')
ylabel('$\gamma(h)$ [m$^2$]')
legend('show')


% % Plot the permeabilities
figure
plot([DataStructOut.DeltaFd], [DataStructOut.permeablAbs], 's')
xlabel('$\Delta f_D$')
ylabel('$k$ [m$^2$]')
title('Absolute permeability')
figure
plot([DataStructOut.lambda], [DataStructOut.permeablAbs], 's')
xlabel('$\lambda$')
ylabel('$k$ [mm$^2$]')
title('Absolute permeability')
end

end