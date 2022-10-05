function [C, G] = CalculateSaveImageConcentrationGradient...
    (originImgFold, genFileName, fr, suff, cropMiddle, idxMidStart, idxMidEnd, ...
    file_i, C0, Cmax, Iback, Delta, fmg, mk, frIdx, mkDil, pixLen, ...
    analyzImgFold2C, analyzImgFold2G, imgTiffName, lengthScale)

% CALCULATE AND SAVE IMAGE CONCENTRATION AND GRADIENTS
% Calculate the concentration and gradients in an image of the experiment
% and saves the images for later analysis

% UPDATES
% 02/11/2020: Calculate the gradients without smoothing with the
% Sobel-Feldman filter.

% Read image I
ImgI = imread(fullfile(originImgFold, [genFileName num2str(fr,'%4.4d') suff]));

% Flip LR (the flow in the original images is from right to left) and
% convert to double
ImgI = double(fliplr(ImgI));

% crop the middle part of the mask
if cropMiddle
ImgI = ImgI(idxMidStart:idxMidEnd,:);
end

% I NEED TO SEE WHAT IS HAPPENING IN THE RAW DATA
if file_i==12
if fr==63 || fr==64 ||  fr==65 ||  fr==66 ||  fr==75 ||  fr==76
ImgI=ImgI./2;
end
end

% Calculate the concentration of solute from image intensity
C = -C0.*log(1-(ImgI-Iback)./Delta);
% Apply filter to smooth the image and improve analysis
C = fmg(C,5);

% Calculate gradients using the Sobel-Feldman operator with a 3-by-3
% smoothing matrix. Also calculate the
% angles of the gradient line.
[~, thetaG] = GradientNormAngles(C);
% Calculate gradients without smoothing
[Gx, Gy] = gradient(C);
G = sqrt(Gx.^2 + Gy.^2);


% % Remove the grains
% C(mk) = 0;
% Remove the grains with the improved mask
C(mkDil) = 0;
% Remove low intensity noise
C(C<0) = 0;

% Save a 16-bit image of the concentrations
C16 = uint16(C/Cmax*(2^16-1));
imwrite(C16, fullfile(analyzImgFold2C, sprintf('C16_fr_%03d.png', frIdx)))

G(1:3,:) = 0;
G(end-2:end,:) = 0;
G(:,1:3) = 0;
G(:,end-2:end) = 0;
G(mkDil) = 0;
% G(mk) = 0;
G = real(G);
G = G./pixLen;
% Save a 16-bit image of the Gradients
G16 = uint16(G);
imwrite(G16, fullfile(analyzImgFold2G, sprintf('G16_fr_%03d.png', frIdx)))


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