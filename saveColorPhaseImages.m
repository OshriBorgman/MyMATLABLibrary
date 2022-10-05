function saveColorPhaseImages(phaseImg, mask, range, folder, filename)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Set the colors for different phases
threeColMap = [0.6 0.6 0.6;...
               0 0.4 1;...
               1 0.2 0];
           
% Trim the grain mask to the correct size
grainMaskTrim = mask(range{1}, range{2});

% Assign values to the different phases    
colorPhaseImage = double(phaseImg);
colorPhaseImage(~grainMaskTrim) = 1;
colorPhaseImage(grainMaskTrim) = 2;
colorPhaseImage(phaseImg) = 3;

if ~exist(fullfile(folder, 'phase_color'), "dir")
    mkdir(fullfile(folder, 'phase_color'))
end

imwrite(colorPhaseImage, threeColMap, fullfile(folder, 'phase_color', ...
    sprintf('phase_col_%s.png', filename(1:end-4))))

end

