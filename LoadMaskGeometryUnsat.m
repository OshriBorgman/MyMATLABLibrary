function [mk, X, idxMidStart, idxMidEnd, mkDil, pixLen, Ro, lengthScale, ...
    Phi, crossSectArea, PeAll, Obstacles_Struct] = LoadMaskGeometryUnsat...
    (cropImage, cropRange, cellWidth, cellApert, Qliquid, Dm, mk)
% % LOAD MASK GEOMETRY UNSATURATED Load and calculate the geometrical parameters and
% features of the mask for the unsaturated experiments

% UPDATES

% crop the middle part of the mask
if cropImage
[Y, X] = size(mk);
idxMidStart = cropRange{1}(1);
idxMidEnd = cropRange{1}(end);
mkResize = mk(idxMidStart:idxMidEnd,:);
else 
[Y, X] = size(mk);    
idxMidStart = 1;
idxMidEnd = size(mk, 1);
end
mkDil = logical(mkResize);

% The actual length of a pixel in meters
pixLen = cellWidth/size(mk, 1);

% Extract the geometry and topology of the cell:
[~, Obstacles_Struct, Constrictions_Struct] = anMaskTopologyNew(~logical(mk), 0, [10 20]);

% The mean radius of grains in pixel units
Ro = round(Obstacles_Struct.mean_radius);

% The characteristic length scale, the mean distance between grains
% (constrictions, without discriminating pore/throats etc.)
lengthScale = Constrictions_Struct.mean_positive_width*pixLen; % 1.4868e-3

% Porosity is calculated from the initial mask, to properly calculate Pe    
Phi = sum(logical(mk(:))) / numel(logical(mk));

% % The mean width of the pore space
% porousMedWidth = (idxMidEnd-idxMidStart) * pixLen * Phi;

% Cross-sectional area in m^2
crossSectArea = cellApert * cellWidth * Phi;

% The Peclet numbers Pe = Q/A*L/Dm
PeAll = Qliquid .* lengthScale ./ (Dm*crossSectArea);
end

