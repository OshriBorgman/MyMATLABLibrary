clear all
close all
%%  Load the basic mask

% Read the cell geoemtry image
mk0 = fliplr(imread('mk260916.png'));
% Create the mask of the grains
mk = logical(mk0);

% Define the dilation mask
dilationMask = strel('disk',3,0);

% Create a dilated grain mask
mkDil = imdilate(mk, dilationMask);

% Divide the mask to regions, where each region will be treated differently
[mkPartA, mkPartB, mkPartC, mkPartD] = DivideGrainMask(mk, [0 1300 2600 3500 size(mkDil,2)]);

%% Make the shifted mask
% The accumulated grain mask
mkDilAccum = mkDil;

% create a shifted grain masks, with increased grain sizes
for n = 1:7
% Create a slightly increasing grain dilation mask, based on the previously
% dilated mask
dilationMask2 = strel('disk',n,0);

% Make the shifting grain mask, in three sections
mkDil2A = imdilate(mkPartA,  strel('disk',n+floor(n/7),0));
mkShiftA = [false(size(mkDil2A,1), n) mkDil2A(:,1:end-n)];
% Add a small shift upstream
mkDil2D = imdilate(mkPartA, strel('disk',6,0));
mkShiftD = [mkDil2D(:,floor(n/5)+1:end) false(size(mkDil2D,1), floor(n/5))];

mkDil2B = imdilate(mkPartB, dilationMask2);
mkShiftB = [false(size(mkDil2B,1), floor(n/2)) mkDil2B(:,1:end-floor(n/2))];
% mkShiftB = [false(size(mkDil2B,1), n) mkDil2B(:,1:end-n)];
% Add a small shift upstream
mkDil2E = imdilate(mkPartB, strel('disk',n,0));
mkShiftE = [mkDil2E(:,floor(n/5)+1:end) false(size(mkDil2E,1), floor(n/5))];

mkDil2C = imdilate(mkPartC, dilationMask2);
% mkShiftC = [false(size(mkDil2C,1), floor(n/3)) mkDil2C(:,1:end-floor(n/3))];
mkShiftC = mkDil2C;
% Add a small shift downstream
mkDil2F = imdilate(mkPartC, strel('disk',n,0));
mkShiftF = [false(size(mkDil2F,1), floor(n/3)) mkDil2F(:,1:end-floor(n/3))];
% Add a small shift upstream
mkDil2J = imdilate(mkPartC, strel('disk',n,0));
mkShiftJ = [mkDil2J(:,floor(n/1.5)+1:end) false(size(mkDil2J,1), floor(n/1.5))];


mkDil2G = imdilate(mkPartD, dilationMask2);
% mkShiftC = [false(size(mkDil2C,1), floor(n/3)) mkDil2C(:,1:end-floor(n/3))];
mkShiftG = mkDil2G;
% Add a small shift downstream
mkDil2H = imdilate(mkPartD, strel('disk',n,0));
mkShiftH = [false(size(mkDil2H,1), floor(n/3)) mkDil2H(:,1:end-floor(n/3))];
% Add a small shift upstream
mkDil2I = imdilate(mkPartD, strel('disk',n,0));
mkShiftI = [mkDil2I(:,floor(n/3)+1:end) false(size(mkDil2I,1), floor(n/3))];

% Assemble the mask
mkShift = mkShiftA+mkShiftB+mkShiftC+mkShiftD+mkShiftE+mkShiftF+mkShiftG+mkShiftH+mkShiftI+mkShiftJ;
mkDilAug = mkDil+mkShift;
% PlotFieldImage(mkDilAug, sprintf('shifted grain mask no. %d', n))
% img0Dil2 = img0;
% img0Dil2(mkDilAug>0) = 0;
mkDilAccum = mkDilAccum + mkShift;

% % Plot
% PlotFieldImage(img0Dil2, sprintf('Dilated grains shifted no. %d', n))
end

% Add a final shift for the early part
mkShiftK = [false(size(mkDil2A,1), 10) mkDil2A(:,1:end-10)];
mkDilAccum = mkDilAccum + mkShiftK;


%%

% Plot the accumulated shift
PlotFieldImage(mkDilAccum, 'Accumulated shifted mask')

% obtain the logical image of the grain mask. Next, save it using imsave
mkShiftFinal = logical(mkDilAccum);
% % dilate everything one last time
% mkShiftFinal = imdilate(mkShiftFinal, strel('disk',1,0));
PlotFieldImage(mkShiftFinal, 'Final logical mask')
