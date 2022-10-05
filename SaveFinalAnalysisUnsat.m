function [SaveConProfAll, SaveConProfFitParAll, SaveDynaVarAll, ...
    SaveConstParamAll, SaveGradProfAll] = SaveFinalAnalysisUnsat(saveIdx, frIdx, CLongProf, ...
    ConcProfParam, VmWidth, VmSave, saveMaxConc, delT0, ...
    GammaLen, saveMeanConc, saveMeanGrad, saveMeanAngleGrad, ...
    saveMaxGrad, gradBinCount, gradPDF, gradPDFEdges, ...
    gradAngleBinCount, gradAnglePDF, gradAnglePDFEdges, numFolds, lOverSigSeg, ...
    lOverRBoundArray, Pe, Q, crossSectArea, Phi, t_a, Dm, ...
    lengthScale, Cmax, C, pixLen, localK, traceLine, foldsIdx, ...
    SaveConProfAll, SaveConProfFitParAll, SaveDynaVarAll, ...
    SaveConstParamAll, SaveGradProfAll, saveGradProf)

% SAVE FINAL ANALYSIS Save the final results from image analysis

% Save the results of the longitudinal concentration profiles analysis
SaveConProfAll{saveIdx} = CLongProf;
SaveConProfFitParAll{saveIdx} = ConcProfParam;

% Save the gradient profiles
SaveGradProfAll{saveIdx}.Profiles = saveGradProf;
SaveGradProfAll{saveIdx}.Pe = Pe;

% Save the results for dynamic variables
% Save the results for the mixing volume analysis
SaveDynaVarAll{saveIdx}.MixingWidth = VmWidth;
SaveDynaVarAll{saveIdx}.MixingVol = VmSave;
% The mean and maximum concentrations during the experiment
SaveDynaVarAll{saveIdx}.MeanSoluteC = saveMeanConc;
SaveDynaVarAll{saveIdx}.MaxSoluteC = saveMaxConc;
SaveDynaVarAll{saveIdx}.Time = (1:frIdx).*delT0;
SaveDynaVarAll{saveIdx}.TimeNorm = (1:frIdx).*delT0/t_a;
% Save the new calculation of advected line Gamma
SaveDynaVarAll{saveIdx}.GammaLen = GammaLen;
% % The mean length of individual segments/fingers composing the advected
% % line
% SaveDynaVarAll{saveIdx}.MeanGammaSegmntLen = meanGammaFingLen;
% % The number of segments/fingers composing the advected line:
% SaveDynaVarAll{saveIdx}.GammSegNum = GammaSegNum;
% Save results for the concentration gradient
SaveDynaVarAll{saveIdx}.GradientMean = saveMeanGrad;
SaveDynaVarAll{saveIdx}.GradientAngleMean = saveMeanAngleGrad;
SaveDynaVarAll{saveIdx}.GradientMax = saveMaxGrad;
SaveDynaVarAll{saveIdx}.GradientBinCount = gradBinCount;
SaveDynaVarAll{saveIdx}.PDFG = gradPDF;
SaveDynaVarAll{saveIdx}.BinDistG = gradBinCount;
SaveDynaVarAll{saveIdx}.EdgesDistG = gradPDFEdges;
% The gradient angles distributions
SaveDynaVarAll{saveIdx}.BinCountGradAngle = gradAngleBinCount;
SaveDynaVarAll{saveIdx}.GradAnglePDF = gradAnglePDF;
SaveDynaVarAll{saveIdx}.GradAnglePDFEdges = gradAnglePDFEdges;
% Save the number of advected line folds
SaveDynaVarAll{saveIdx}.LineFoldNum = numFolds;
% SaveDynaVarAll{saveIdx}.LenOverSigma = lOverSigSeg;
% SaveDynaVarAll{saveIdx}.LenOverBound = lOverRBoundArray;
% The indices of the mixing front line
SaveDynaVarAll{saveIdx}.MixFront = traceLine;
% % The values of local curvatures along the front
% SaveDynaVarAll{saveIdx}.LocalCurv = localK;
% The indices of the folding points on the interface line
SaveDynaVarAll{saveIdx}.FoldIdx = foldsIdx;


% Save the general experimental parameters
SaveConstParamAll{saveIdx}.Pe = Pe;
SaveConstParamAll{saveIdx}.FlowRate = Q;
SaveConstParamAll{saveIdx}.CrossSection = crossSectArea;
SaveConstParamAll{saveIdx}.Porosity = Phi;
SaveConstParamAll{saveIdx}.AdvecTime = t_a;
SaveConstParamAll{saveIdx}.DiffCoeff = Dm;
SaveConstParamAll{saveIdx}.Deltat = delT0;
SaveConstParamAll{saveIdx}.PixelLen = pixLen;
SaveConstParamAll{saveIdx}.CharLen = lengthScale;
% The maximum concnetration of the solute pulse
SaveConstParamAll{saveIdx}.C0 = Cmax;
% The cell dimensions in meters
SaveConstParamAll{saveIdx}.Xsize = size(C, 2)*pixLen;
SaveConstParamAll{saveIdx}.Ysize = size(C, 1)*pixLen;


% Save the concentration and gradient fields


end

