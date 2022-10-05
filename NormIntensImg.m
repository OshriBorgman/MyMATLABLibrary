function [g, CC] = NormIntensImg(f, mask, b, d)
% NORMALIZE INTENSITY IMAGES Normalize intensity images according to bright
% and dark images, to correct uneven lighting conditions

% INPUT
% f = input image
% d = dark image
% b = bright image
% mask = grain mask image

% OUTPUT
% CC = normalized image
% g = corrected image

% normalization method, 0 for bright image only, 1 for dark and bright
% images
if nargin>3
    normMeth = 1;
else
    normMeth = 0;
end


switch normMeth
    case 0
% Calculate the normalized image based on bright image only
        CC = (f)./(b);
    case 1
% Calculate the normalized image based on dark and bright images
        CC = (f-d)./(b-d);
end

% Rescale to retrieve the original color
g = CC.*mean(f(mask))./mean(CC(mask));

end

