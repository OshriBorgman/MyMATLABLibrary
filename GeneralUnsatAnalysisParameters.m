% % GENERAL UNSATURATED ANALYSIS PARAMETERS
% These parameters are used by the analysis code 'UnsatImageAnalysis.mlx'

% The minimum and maximum relative concentration in the mixing zone
mixZoneMinC = 0.05;
mixZoneMaxC = 0.95;

% The maximum concentration
Cmax = 1;

% The sample width in [m]
cellWidth = 0.06;
% The sample length in [m]
cellLength = 0.15;

% The cell thickness (aperture) in meters
cellApert=1e-3; 

% Molecular diffusion coefficient of fluoresceine NEEDS VERIFICATION
Dm=5.4e-10;

% Create the mask to dilate the grains, to remove some concentration and
% gradient values just around the grains
dilationMask = strel('disk',10,0);

% % Set an initial frame difference to compensate for the advection time
% initialFramDiff = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 10];
