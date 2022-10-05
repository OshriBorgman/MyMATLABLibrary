function [Cm, xfit, Cmmat, Cerf, CLongProf, ConcProfParam, GMean, xGrad, ...
    yGrad, centOfMassIdx, fitCurveMaxVal, fitCurveMaxIdx, CMeanPlot, momentGrad1Idx] = ...
    MeanLongConcGradUnsat...
    (C, mkDil, pixLen, X, poreLen, Cmax, Cmin, moderf, frIdx, delT0, CLongProf, ...
    ConcProfParam, G, Csup_ratio, throatWid)

% CALCULATE THE MEAN LONGITUDINAL CONCENTRATION This function calcualtes
% the mean longitudinal concentration profile of the sample
% In addition, we calculate the mean gradient profile along the flow
% direction and compare it with the concentration profile.
% ADDED 21/12/2020: calculate the second moment of the longitudinal
% concentration profile

%% Average concentration along the flow direction 

Cm = sum(C.*mkDil)./sum(mkDil);
x = (1:numel(Cm)).*pixLen;
y = Cm(1:end);

% The distance and concentration for fitting the concentration profile
xfit = x;%(1:(X-poreLen));
yfit = y;%(1:(X-poreLen));
% The estimated position of x0, the location of c0/2
[~,tpindmin0] = min(abs(yfit-Cmax/2));
x0 = xfit(tpindmin0);
% The estimated width of the plume
[~,xMax] = min(abs(yfit-Cmax));
[~,xMin] = min(abs(yfit-Cmin));
std0 = abs(xfit(xMin-xMax));
% The preliminary parameter values
p0 = [Cmax x0 std0 Cmin];
mdl = fitnlm(xfit,yfit,moderf,p0);
paramerf=[mdl.Coefficients.Estimate]';
Cmmat(frIdx,:) = yfit;
Cerf(frIdx,:) = [paramerf];

% Save the following data: x and y data for measured longitudinal profiles,
% x and y data of the fitted profile, and the fitted parameters
CLongProf(frIdx).xDataMeas = (1:length(Cm))*pixLen;
CLongProf(frIdx).yDataMeas = Cm;
CLongProf(frIdx).xDataFit = xfit;
CLongProf(frIdx).yDataFit = (moderf(paramerf,xfit));
CLongProf(frIdx).t = frIdx*delT0;
CLongProf(frIdx).concVarProf = std0;
CLongProf(frIdx).meanPosProf = x0;
CLongProf(frIdx).Cmax = Cmax;
CLongProf(frIdx).Cmin = Cmin;

% Collect the data for the entire experiment
ConcProfParam(frIdx).b1 = paramerf(1);
ConcProfParam(frIdx).b2 = paramerf(2);
ConcProfParam(frIdx).b3 = paramerf(3);
ConcProfParam(frIdx).b4 = paramerf(4);

%% Calculate the longitudinal profile of the second moment of the concentration field
% Use the local concentration to calculate the difference, and in the end
% divide by it, to normalize the plot
CLongProf(frIdx).concVarProf = sqrt(sum(((C/Cmax-sum((C/Cmax).*mkDil)./...
    sum(mkDil)).*mkDil).^2)./sum(mkDil))./(sum((C/Cmax).*mkDil)./sum(mkDil));

%% Analyze the gradient longitudinal profiles

% Average gradient along the flow direction (without the grains and the
% noisy region outside the support concentration)
% GMean = sum(G.*~mk)./sum(~mk);
GMean = sum(G.*mkDil)./sum(mkDil);
% Replace NaNs with zeros
GMean(isnan(GMean)) = 0;

% The x- and y-coordinates
xGrad = (1:numel(GMean)).*pixLen;
yGrad = GMean(1:end);

% Discard the values at the beginning of the flow field, from the first
% pore length
GMean(1:round(throatWid/pixLen)) = 0;

% 1. The location of the maximum longitudinal mean gradient
[maxGmVal, maxGmIdx] = max(GMean);
% Normalize the concentration profile
CMeanPlot = Cm/Cmax;
% and the gradient profile, 
GMeanPlot = GMean.*throatWid/Cmax;
% Indicate the location of the center of mass of the concentration profile
[~, centOfMassIdx] = min(abs(CMeanPlot-0.5));
% Save the average concentration at the location of the maximum value of the gradient profile
maxGradConc = CMeanPlot(maxGmIdx);


% 2. Calculate the first moment of the gradient profile, the location of the
% gradient profile's center of mass in meters
momentGrad1 = sum(xGrad.*GMean)/sum(GMean);
% Convert the location to pixel index location
momentGrad1Idx = round(momentGrad1/pixLen);
% Calculate the gradient of the fitted concentration profile
gradCMean = diff(CLongProf(frIdx).yDataFit, 2);


% % And after smoothing
% GMeanPlotSmooth = smoothdata(GMeanPlot, 'movmean', 250);
% % Indicate the location of the maximum gradient and the center of mass of
% % the concentration profile
% [~, centOfMassIdx] = min(abs(CMeanPlot-0.5));
% [maxGmVal, maxGmIdx] = max(GMeanPlotSmooth);

% % 3a. Fit a gaussian to the gradient curve
% % Set up fittype and options.
% ft = fittype( 'gauss2' );
% opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
% opts.Display = 'Off';
% [fitresult, gof] = fit( xGrad', GMean', ft, opts );
% % The x-value of the fitted maximum, with the higher gradient value
% [~, maxGradFitIdx] = max([fitresult(fitresult.b1)*(fitresult.b1>0 && fitresult.b1<90), ...
%     fitresult(fitresult.b2)*(fitresult.b2>0 && fitresult.b2<90)]);
% fitMaxVals = [fitresult.b1, fitresult.b2];
% fitGradMaxLoc = fitMaxVals(maxGradFitIdx);
% fitGradMaxIdx = round(fitGradMaxLoc/pixLen*lengthScale);

% % 3b. Use the fitted curve and get the maximum value and it's longitudinal position 
% fittedCurve = fitresult(xGrad');
% [fitCurveMaxVal, fitCurveMaxIdx] = max(fittedCurve);
% fitGradMaxIdx = fitCurveMaxIdx*pixLen/lengthScale;

centOfMassIdx = [];
fitCurveMaxVal = [];
fitCurveMaxIdx = [];

end

