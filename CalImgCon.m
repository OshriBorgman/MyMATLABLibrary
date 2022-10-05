function [CImage] = CalImgCon(img, mask, mdl, curveType, iB, i0)
% CALCULATE IMAGE CONCENTRATION Calculate image concentration from
% intensity image and calibration curve

% INPUT
% img - The image to calculate concentrations on
% mask - The grain mask image
% mdl - The fitted model object
% curveType - the type of fitted curve: "poly" for a (2nd order)
% polynomial, "exp" for exponential
% iB, i0 - background intensity and maximum intensity for the exponential
% model fit

% OUTPUT
% CImage - The calculated concentration image

if strcmp(curveType,'exp') && nargin<6
    error("Missing parameters for exponential calibration curve")
end

switch curveType
    case 'poly'
        
        % Calculate the concentrations according to the polynomial calibration curve
        solveCCoeff = {mdl.Coefficients.Estimate(1)-img.*mask; ...
            mdl.Coefficients.Estimate(2); mdl.Coefficients.Estimate(3)};
        [CImage,~] = SolveQuad(solveCCoeff);
        CImage = real(CImage);
        
    case 'exp'
        
        % calculate the factor in the logarithm
        var1 = 1-(img-iB)/i0;
        % Zero the negative values
        var1(var1<0) = eps;
        % Calculate the concentrations according to the exponential calibration curve
        CImage = -log(var1).*mdl.Coefficients.Estimate;    
        
end

