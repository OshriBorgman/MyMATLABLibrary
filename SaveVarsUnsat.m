function [varargout] = SaveVarsUnsat(Nframes, fluidPhaseImg0, ...
    grainMaskTrim, Qliq, SampleDataStruct, delT, pixLen, CMax, CMin)
% SAVE-PLOT VARIABLES Create the variables for saving data and plotting

% The variable to save the longitudinal average concentration
varargout{1}.xDataMeas = cell(Nframes,1);
varargout{1}.yDataMeas = cell(Nframes,1);
varargout{1}.xDataDiff = cell(Nframes,1);
varargout{1}.yDataDiff = cell(Nframes,1);
varargout{1}.concVarProf = cell(Nframes,1);
varargout{1}.meanPosProf = cell(Nframes,1);

% Variables for saving the gradients and concentrations
varargout{2}.saveMeanGrad = zeros(Nframes,1);
varargout{2}.saveMeanConc = zeros(Nframes,1);
varargout{2}.saveTotalMass = zeros(Nframes,1);
varargout{2}.saveVarConc = zeros(Nframes,1);
varargout{2}.SpatMomOne = zeros(Nframes,2);
varargout{2}.SpatMomTwo = zeros(Nframes,2);
varargout{2}.Time = zeros(Nframes,1);
% The width of the mixing zone
varargout{2}.mixZoneWidth = zeros(Nframes,1);
% The area of mixing zone
varargout{2}.mixZoneArea = zeros(Nframes,1);
% The mixing front
varargout{2}.mixFrontLen = zeros(Nframes,1);
varargout{2}.mixFrontIdx = cell(Nframes,1);
% The spatial moments of the solute plume
varargout{2}.SpatMomOne = zeros(Nframes,2);
varargout{2}.SpatMomTwo = zeros(Nframes,2);

% Variables for saving the distributions of concentrations, gradients, etc. 
varargout{3}.CLinN = cell(Nframes,1);
varargout{3}.CLinEdgs = cell(Nframes,1);
varargout{3}.CLog = cell(Nframes,1);
varargout{3}.CLogEdgs = cell(Nframes,1);
varargout{3}.CVarLinN = cell(Nframes,1);
varargout{3}.CVarLinEdgs = cell(Nframes,1);
varargout{3}.CVarLogN = cell(Nframes,1);
varargout{3}.CVarLogEdgs = cell(Nframes,1);
varargout{3}.CGradLinN = cell(Nframes,1);
varargout{3}.CGradLinEdgs = cell(Nframes,1);
varargout{3}.CGradLogN = cell(Nframes,1);
varargout{3}.CGradLogEdgs = cell(Nframes,1);


% Calculate saturation
satDegree = 1-sum(fluidPhaseImg0, "all")/sum(grainMaskTrim, "all");
% The longitudinal saturation
satDegreeLong = 1-sum(fluidPhaseImg0)./sum(grainMaskTrim);

% The average throat size in m, calculated from the analysis of the sample
% design
wAvg = mean(SampleDataStruct.throatHalfLength.*2)*1e-3;
% The average pore diameter [m]
meanPoreDiam = mean(SampleDataStruct.PoreDiameters)*1e-3;
% Pore space aperture (pillar height)
b = 1e-3; % [m]

% The cross-section area of the cell
crossSecArea = b*SampleDataStruct.W*1e-3; %[m^2]

% The surface tension for 20% w/w glycerol at 20 degrees, according to Takamura et al. 2012 https://doi.org/10.1016/j.petrol.2012.09.003.
gammaGlWatAir = 0.0717; % [N/m]

% The average pore velocity [m/s]
vLiq = Qliq/(crossSecArea*SampleDataStruct.porosity*satDegree);

% The advection time
tAdv = meanPoreDiam/vLiq;

% The weight fraction of glycerol in water
w_g = 0.2;
% The temperature in deg. C
T = 20;
% The viscosity of glycerol-water mixture
[rho_s, mu_s] = densityViscosityWaterGlycerolSolution(w_g, T);
% Calculate the diffusion coefficient
[Dm] = CalcDiffCoeff(w_g);
% Calculate flow non-dimensional numbers
[varargout{4}, Pe, Re, Ca] = CalcFlowNonDimNum(wAvg, meanPoreDiam, vLiq, Dm, ...
    SampleDataStruct, rho_s, mu_s, Qliq, gammaGlWatAir, crossSecArea, SampleDataStruct.porosity);

% Append the saved data file
% The flow cell aperture in [m]
varargout{4}.CellApp = b;
% The liquid flow rate in m^3/sec
varargout{4}.LiqFloRate = Qliq;
varargout{4}.DeltaT = delT;
% The diffusion coefficient [m^2/s]
varargout{4}.DiffCoeff = Dm;
varargout{4}.AdvTime = tAdv;
varargout{4}.MeanVel = vLiq;
varargout{4}.Saturation = satDegree;
varargout{4}.CrossSecArea = crossSecArea;
varargout{4}.LenPix = pixLen;
varargout{4}.CMax = CMax;
varargout{4}.CMin = CMin;

end