function [imgOut] = PhaseSepHist(imgIn, varargin)
%PHASESEPHIST Separate phases in images using the intensity histogram
%   Takes an intensity image and finds a local minima in the intensity
%   histogram, and uses this minima to threshold the image and separate
%   into two phases.
%   INPUT:
%   imgIn: The input image (double)
%   varargin: optional input; 1- the number of local minima in the
%   hostogram, 2- the minimum separation to define the local minima.
%   OUTPUT:
%   imgOut: the output image of pixels above the threshold (logical)

if isempty(varargin)
    numExtr = 1;
    minSep = 20;
elseif length(varargin)==1
    numExtr = varargin{1};
    minSep = 20;
elseif length(varargin)==2
    numExtr = varargin{1};
    minSep = varargin{2};
end

%     %     Collect the histogram of the image
[B, E] = histcounts(nonzeros(imgIn));
%     Find the threshold for the phase distribution from the local minimum
phaseThresh = E(find(islocalmin(B, "MaxNumExtrema", numExtr, "MinSeparation", minSep)));
imgOut = logical(imgIn);
imgOut(imgIn<phaseThresh) = false;
imgOut(imgIn>=phaseThresh) = true;
end

