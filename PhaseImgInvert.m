function [phaseimg1] = PhaseImgInvert(phase_img_in,immobile_phase_img)
%PHASE IMAGE INVERTED An image of an isolated phase from a three phase image

%   This functions takes a three-phase (i.e. two mobile, one stationary)
%   and isolates the phase originally in the background

% Isolate phase 1
phaseimg1raw = ~logical(phase_img_in+~immobile_phase_img);
% phaseimg1raw_props = regionprops(phaseimg1raw, 'Area');
% Filter out small clusters
phaseimg1 = bwpropfilt(phaseimg1raw, 'Area', [100 inf]);

end

