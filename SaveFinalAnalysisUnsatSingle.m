function [SaveConProfAll, SaveConProfFitParAll, SaveDynaVarAll, ...
    SaveConstParamAll] = SaveFinalAnalysisUnsat(frNum, CLongProf, ...
    ConcProfParam, gradBinCount, gradPDFEdges, saveMeanGrad, VmWidth, ...
    VmArea, Cmax, Cmin, SampleDataStruct)

% SAVE FINAL ANALYSIS FOR SINGLE EXPERIMENT Save the final results from image analysis

% Save the results of the longitudinal concentration profiles analysis
SaveConProfAll = CLongProf;
SaveConProfFitParAll = ConcProfParam;

% % Save the results for dynamic variables
% Save the results for the mixing volume analysis
SaveDynaVarAll.MixingWidth = VmWidth;
SaveDynaVarAll.MixingArea = VmArea;
% % The mean and maximum concentrations during the experiment
% SaveDynaVarAll.MeanSoluteC = saveMeanConc;
% SaveDynaVarAll.MaxSoluteC = saveMaxConc;
SaveDynaVarAll.Time = (1:frNum).*SampleDataStruct.DeltaT;
SaveDynaVarAll.TimeNorm = (1:frNum).*SampleDataStruct.DeltaT/SampleDataStruct.AdvTime;
% Save results for the concentration gradient
SaveDynaVarAll.GradientMean = saveMeanGrad;
SaveDynaVarAll.GradientBinCount = gradBinCount;
SaveDynaVarAll.EdgesDistG = gradPDFEdges;

% Save the general experimental parameters
SaveConstParamAll.Pe = SampleDataStruct.PecNum;
SaveConstParamAll.FlowRate = SampleDataStruct.LiqFloRate;
SaveConstParamAll.CrossSection = SampleDataStruct.CrossSecArea;
SaveConstParamAll.Porosity = SampleDataStruct.porosity;
SaveConstParamAll.AdvecTime = SampleDataStruct.AdvTime;
SaveConstParamAll.DiffCoeff = SampleDataStruct.DiffCoeff;
SaveConstParamAll.Deltat = SampleDataStruct.DeltaT;
SaveConstParamAll.PixelLen = SampleDataStruct.LenPix;
SaveConstParamAll.CharPorLen = mean(SampleDataStruct.PoreDiameters);
SaveConstParamAll.CharThrWid = mean(SampleDataStruct.throatHalfLength)*2;
% The maximum concnetration of the solute pulse
SaveConstParamAll.Cmax = Cmax;
SaveConstParamAll.Cmin = Cmin;
% The cell dimensions in meters
SaveConstParamAll.Xsize = SampleDataStruct.Lx;
SaveConstParamAll.Ysize = SampleDataStruct.Ly;
SaveConstParamAll.Disorder = SampleDataStruct.DeltaFd;
SaveConstParamAll.CorrLength = SampleDataStruct.lambda;
SaveConstParamAll.MeshL = SampleDataStruct.MeshLen;

end

