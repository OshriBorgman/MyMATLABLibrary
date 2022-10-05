function [CLongProf, saveGradProf, ConcProfParam, saveMeanGrad, saveMeanAngleGrad, ...
    saveMaxGrad, gradBinCount, gradPDF, gradPDFEdges, saveMeanConc, ...
    saveMaxConc, gradAngleBinCount, gradAnglePDF, gradAnglePDFEdges, ...
    VmWidth, VmSave, advLineElong, GammaLen, meanGammaFingLen, ...
    GammaSegNum, Xg, Yg, lOverSigSeg, lOverRBoundArray, SigSeg, numFolds, localK, traceLine, foldsIdx] = ...
    SavePlotVarsUnsat(Nframes, mk)
% SAVE-PLOT VARIABLES Create the variables for saving data and plotting

% The variable to save the longitudinal average concentration
CLongProf.xDataMeas = [];
CLongProf.yDataMeas = [];
CLongProf.xDataFit = [];
CLongProf.yDataFit = [];
CLongProf.t = [];
CLongProf.concVarProf = [];
CLongProf.meanPosProf = [];
CLongProf.Cmax = [];
CLongProf.Cmin = [];

ConcProfParam.b1 = [];
ConcProfParam.b2 = [];
ConcProfParam.b3 = [];
ConcProfParam.b4 = [];

% Variables for saving the gradients and concentrations
saveMeanGrad = zeros(Nframes,1);
saveMeanAngleGrad = zeros(Nframes,1);
saveMaxGrad = zeros(Nframes,1);
gradBinCount = zeros(Nframes,100);
gradPDF = zeros(Nframes,100);
gradPDFEdges = zeros(Nframes,101);
saveMeanConc = zeros(Nframes,1);
saveMaxConc = zeros(Nframes,1);
gradAngleBinCount = zeros(Nframes,100);
gradAnglePDF = zeros(Nframes,100);
gradAnglePDFEdges = zeros(Nframes,101);
saveGradProf = [];

% The width of the mixing zone
VmWidth = zeros(Nframes,1);
% The volume of mixing zone
VmSave = zeros(Nframes,1);

% The advected line elongation
advLineElong.Time = [];
advLineElong.Mean = [];
advLineElong.MeanNew = [];
advLineElong.MeanAngle = [];
advLineElong.AboveBelow = [];
GammaLen = [];
meanGammaFingLen = [];
GammaSegNum = [];
% The grid for plotting the advected line
[Xg,Yg] = meshgrid(1:size(mk,2),1:size(mk,1));  

% Variables to save the advected line folding attributes
lOverSigSeg = cell(Nframes,1);
lOverRBoundArray = cell(Nframes,1);
SigSeg = cell(Nframes,1);
numFolds = zeros(Nframes,1);
localK = cell(Nframes,1);
traceLine = cell(Nframes,1);
foldsIdx = cell(Nframes,1);
end

