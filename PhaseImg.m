function [phaseimg1,phaseimg2] = PhaseImg(phase_img_in,immobile_phase_img)
%PHASE IMAGE An image of an isolated phase from a three phase image

%   This functions takes a three-phase (i.e. two mobile, one stationary)
%   and isolates each one of the mobile phases in its own image

% Isolate phase 1
phaseimg1raw = ~logical(phase_img_in+~immobile_phase_img);
% phaseimg1raw_props = regionprops(phaseimg1raw, 'Area');
% Filter out small clusters
phaseimg1 = bwpropfilt(phaseimg1raw, 'Area', [100 inf]);

% Isolate phase 1
phaseimg2raw = logical(phase_img_in+~immobile_phase_img);
% phaseimg2raw_props = regionprops(phaseimg2raw, 'Area');
% Filter out small clusters
phaseimg2 = bwpropfilt(phaseimg2raw, 'Area', [100 inf]);

end

