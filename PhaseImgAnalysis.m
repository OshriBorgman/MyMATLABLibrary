function [outStruct, phaseImgLabel, phaseImgProps] = PhaseImgAnalysis(inImg, ...
    mask, lenUni)

% Label the clusters
phaseImgLabel = bwlabel(inImg);
% Obtain the properties of the non-aqueous phase
phaseImgProps = regionprops(inImg, "Area", "Orientation", "Perimeter", ...
    "Centroid", "PixelIdxList");

% % Calculate general statistics
% The number of clusters
clustNum = length(phaseImgProps);
% The average area in length units
clustAreaMean = mean([phaseImgProps(:).Area]).*lenUni^2;
% The average orientation in degrees, 0 is aligned with the main flow
% direction, 90 is perpendicular
clustOrientMean = mean([phaseImgProps(:).Orientation]);
% The average cluster perimeter length in length units
clustPerimeterMean = mean([phaseImgProps(:).Perimeter]).*lenUni;
% The centroid position of the cluster
clusterCent = [phaseImgProps.Centroid].*lenUni;

% Calculate the saturation profiles
[longProfile, transProfile] = CalcSatProfiles(~inImg.*mask, mask, 0);

% Calculate the Minkowski functionals for the non-wetting phase
[minkowskiOutNonWet] = MinkowskiFuncs(inImg, mask, lenUni);
% Calculate the Minkowski functionals for the wetting phase
[minkowskiOutWet] = MinkowskiFuncs(mask-inImg, mask, lenUni);

% Calculate the average distances between non-wetting phase clusters
[nonwetClustDist] = clusterPerimDist(phaseImgProps, phaseImgLabel);
nonwetClustDist = mean(nonwetClustDist);

% Construct one structure to save the analyses
[outStruct] = pack_structure(clustNum, clustAreaMean, clustOrientMean, ...
    clustPerimeterMean, clusterCent, minkowskiOutNonWet, minkowskiOutWet, ...
    longProfile, transProfile, phaseImgProps, nonwetClustDist);

end

% A shorter version of the main function to compute the properties of the non aqueous phase
function [outStruct] = PhaseImgAnalysisShort(inImg, mask, lenUni)

% Label the clusters
phaseImgLabel = bwlabel(inImg);
% Obtain the properties of the non-aqueous phase
phaseImgProps = regionprops(inImg, "Area", "Orientation", "Perimeter", ...
    "Centroid", "PixelIdxList");

% % Calculate general statistics
% The number of clusters
clustNum = length(phaseImgProps);
% The average area in length units
clustAreaMean = mean([phaseImgProps(:).Area]).*lenUni^2;
% The average orientation in degrees, 0 is aligned with the main flow
% direction, 90 is perpendicular
clustOrientMean = mean([phaseImgProps(:).Orientation]);
% The average cluster perimeter length in length units
clustPerimeterMean = mean([phaseImgProps(:).Perimeter]).*lenUni;
% The centroid position of the cluster
clusterCent = [phaseImgProps.Centroid].*lenUni;

% Calculate the saturation profiles
[longProfile, transProfile] = CalcSatProfiles(~inImg.*mask, mask, 0);

% Construct one structure to save the analyses
[outStruct] = pack_structure(clustNum, clustAreaMean, clustOrientMean, ...
    clustPerimeterMean, clusterCent, longProfile, transProfile, phaseImgProps);

end