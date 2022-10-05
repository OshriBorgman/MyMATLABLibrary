function [C, G, grainMaskUnsat] = SaveImageConcGradPixByPix...
    (rawImgPath, rawImgFiles, PointCall, cropMiddle, imgRange, ...
    fmg, unsatMaskImg, frIdx, pixLen, concImgsFolder, gradImgsFolder)

% SAVE IMAGES OF CONCENTRATION AND GRADIENTS WITH PIXEL-BY-PIXEL
% CALIBRATION
% Calculate the concentration field of an image according to a
% pixel-by-pixel calibration curve

% UPDATES

% Read image I
ImgI = imread(fullfile(rawImgPath, rawImgFiles(frIdx).name));

% Flip LR (the flow in the original images is from right to left) and
% convert to double
ImgI = double(fliplr(ImgI))./(2^16-1);

% crop the middle part of the mask
if cropMiddle
ImgI = ImgI(imgRange{1}, imgRange{2});
PointCall.Intercept = PointCall.Intercept(imgRange{1}, imgRange{2});
PointCall.Slope = PointCall.Slope(imgRange{1}, imgRange{2});
unsatMaskImg = unsatMaskImg(imgRange{1}, imgRange{2});
end

% Calculate the concentration based on calibration matrices
C = (ImgI-PointCall.Intercept)./PointCall.Slope;
C(grainMaskUnsat) = ImgI(grainMaskUnsat);
% Apply filter to smooth the image and improve analysis
C = fmg(C,5);

% Calculate gradients. Also calculate the angles of the gradient line.
[~, thetaG] = GradientNormAngles(C);
% Calculate gradients without smoothing
[Gx, Gy] = gradient(C);
% Calculate the magnitude
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
G = real(G);
G = G./pixLen;
% Save a 16-bit image of the Gradients
G16 = uint16(G);
imwrite(G16, fullfile(gradImgsFolder, sprintf('G16_fr_%03d.png', frIdx)))

end