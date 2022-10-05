function [SampleDataStruct] = PorSamplChar(grainMask, imgRange, pixLen, sampleWidth)

% % Calculate porous sample characteristics

[grainX, grainR] = imfindcircles(~grainMask, [10 40]);
SampleDataStruct.XGrains = grainX.*pixLen;
SampleDataStruct.DGrains = 2*grainR.*pixLen;

Lx = length(imgRange{2})*pixLen;
Ly = length(imgRange{1})*pixLen;

% Calculate porosity
phi = 1 - pi / 4 .* sum(SampleDataStruct.DGrains.^2) / (Lx * Ly);

SampleDataStruct.Lx = Lx;
SampleDataStruct.Ly = Ly;
SampleDataStruct.porosity = phi;
SampleDataStruct.W = sampleWidth;

[SampleDataStruct] = CalculateSampleGeometryMultiple(SampleDataStruct, false, ...
    false, false, false, false);
[SampleDataStruct] = AnalyzePoreSizeFun(SampleDataStruct, false);
close

end