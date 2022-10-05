function [C16, G16] = Open16bitImgUnsat(imgIdx, plotIm, analyzImgFoldC, ...
    analyzImgFoldG, readConc, readGrad)

% OPEN 16 BIT IMAGE Open 16 bit images and convert back to double precision
% matrix, for specific tau and Peclet

% INPUT
% plot: Plot the opened image

if readConc
C16 = imread(fullfile(analyzImgFoldC, sprintf('C16_fr_%03d.png', imgIdx)));
end

if readGrad
G16 = imread(fullfile(analyzImgFoldG, sprintf('G16_fr_%03d.png', imgIdx)));
end

if plotIm

figure;
imagesc(C16)
axis equal tight
title('Concentration')

figure;
imagesc(G16)
axis equal tight
title('Gradients')

end

