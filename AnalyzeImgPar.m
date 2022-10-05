function [saveMeanGradOut, saveMeanConcOut,saveVarConcOut, TimeOut, ...
    mixZoneWidthOut, mixZoneAreaOut, mixFrontLenOut, mixFrontIdxOut, ...
    xDataMeasOut, yDataMeasOut, xDataDiffOut, yDataDiffOut] = ...
    AnalyzeImgPar(loadImageIdx, i, n, rawImgsFolder, conImgFile, imgRange, grainMaskTrim, ...
    brightImg, mdl, Iback, I0, nFilt, unsatMaskConc, unsatMaskGrad, ...
    pixLen, CMax, CMin, CMixThreshHigh, CMixThreshLow, SampleDataStruct, ...
    plotFlag, plotFlag2, sat_unsat, grainMaskDil, saveFlag, delT)

fprintf('Reading image %d of %d\n', n, length(loadImageIdx))

[imgNorm] = loadNormCImage(rawImgsFolder, conImgFile.name, imgRange, ...
    grainMaskTrim, brightImg);

% Calculate the concentration image
[CImage] = CalImgCon(imgNorm, grainMaskTrim, mdl, 'exp', Iback, I0);

% Filter the images to reduce noise
CImageFilt = imfilter(CImage, ones(nFilt)./(nFilt^2));

% Remove the grains/air clusters
CImageFilt(~unsatMaskConc) = 0;

[~, G, mixZone] = calcGradImages(CImageFilt, unsatMaskConc, ...
    unsatMaskGrad, pixLen, conImgFile.name, CMax, CMin, CMixThreshHigh, CMixThreshLow, ...
    SampleDataStruct, plotFlag, plotFlag2, sat_unsat, grainMaskDil);

if saveFlag
    % Save image as 16 bit
    CImg16 = uint16(CImageFilt./CMax*(2^16-1));
    GImg16 = uint16(G./CMax);
    if ~exist(fullfile(analyzImgsFolder, 'conc'), "dir")
        mkdir(fullfile(analyzImgsFolder, 'conc'))
        mkdir(fullfile(analyzImgsFolder, 'grad'))
    end
    imwrite(CImg16, fullfile(analyzImgsFolder, 'conc', sprintf('C_16_%03d.png', i)))
    imwrite(GImg16, fullfile(analyzImgsFolder, 'grad', sprintf('G_16_%03d.png', i)))
    fprintf('Saving image %d of %d\n', n, length(loadImageIdx))
end

%     Use this for parfor loops
[saveMeanGradOut, saveMeanConcOut,saveVarConcOut, TimeOut, ...
    mixZoneWidthOut, mixZoneAreaOut, mixFrontLenOut, mixFrontIdxOut, ...
    xDataMeasOut, yDataMeasOut, xDataDiffOut, yDataDiffOut] = ...
    CalculateVarsPar(i, CImageFilt, G, unsatMaskConc, unsatMaskGrad, ...
    mixZone, delT, pixLen, CMax);

end