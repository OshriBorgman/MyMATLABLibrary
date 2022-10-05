function [C, G, grainMaskUnsat] = SaveNormalizeImageConcentrationGradient...
    (rawImgPath, rawImgFiles, refImg, cropMiddle, imgRange, ...
    fmg, grainMask, unsatMaskImg, frIdx, pixLen, concImgsFolder, gradImgsFolder)

% SAVE NORMALIZED IMAGE CONCENTRATION AND GRADIENTS
% Normalize the concentration field of an image according to a reference
% and calculate the gradients

% UPDATES

% Read image I
ImgI = imread(fullfile(rawImgPath, rawImgFiles(frIdx).name));

% Flip LR (the flow in the original images is from right to left) and
% convert to double
ImgI = double(fliplr(ImgI))./(2^16-1);

% % crop the middle part of the mask
% if cropMiddle
% ImgI = ImgI(imgRange{1}, imgRange{2});
% refImg = refImg(imgRange{1}, imgRange{2});
% grainMask = grainMask(imgRange{1}, imgRange{2});
% unsatMaskImg = unsatMaskImg(imgRange{1}, imgRange{2});
% end

% Omit the air clusters from the grain mask
grainMaskUnsat = grainMask;
grainMaskUnsat(unsatMaskImg) = 0;

% Normalize the concentration based on a reference image
C = zeros(size(ImgI));
C(grainMaskUnsat) = ImgI(grainMaskUnsat)./refImg(grainMaskUnsat);
% Apply filter to smooth the image and improve analysis
C = fmg(C,5);

% Calculate gradients using the Sobel-Feldman operator with a 3-by-3
% smoothing matrix. Also calculate the
% angles of the gradient line.
[~, thetaG] = GradientNormAngles(C);
% Calculate gradients without smoothing
[Gx, Gy] = gradient(C);
G = sqrt(Gx.^2 + Gy.^2);

% Remove the grains with the improved mask
C(~grainMaskUnsat) = 0;
% Remove low intensity noise
C(C<0) = 0;

% Save a 16-bit image of the concentrations
C16 = uint16(C*(2^16-1));
imwrite(C16, fullfile(concImgsFolder, sprintf('C16_fr_%03d.png', frIdx)))

G(1:3,:) = 0;
G(end-2:end,:) = 0;
G(:,1:3) = 0;
G(:,end-2:end) = 0;
G(~grainMaskUnsat) = 0;
% G(mk) = 0;
G = real(G);
G = G./pixLen;
% Save a 16-bit image of the Gradients
G16 = uint16(G);
imwrite(G16, fullfile(gradImgsFolder, sprintf('G16_fr_%03d.png', frIdx)))


% % % Remove reflection from grains for the gradient calculation
% % [refmapDil] = RefMaskForGrad(imgTiffName, mkDil, 0);
% % Remove reflection from grains for the gradient calculation
% [refmapDil] = RefMaskForGrad(imgTiffName, mk, 0);
% GClean = G;
% GClean(find(refmapDil)) = 0;
% % Divide by the unit of pixel length 
% GClean = GClean./pixLen;

% % Save a 16-bit image of the Gradients
% G16 = uint16(GClean);
% imwrite(G16, fullfile(analyzImgFold2G, sprintf('G16_fr_%03d.png', frIdx)))

end