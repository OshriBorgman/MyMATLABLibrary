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

% The overall saturation degree
satDegree = 1-sum(inImg, "all")/sum(mask, "all");

% Construct one structure to save the analyses
[outStruct] = pack_structure(satDegree, clustNum, clustAreaMean, clustOrientMean, ...
    clustPerimeterMean, clusterCent, phaseImgProps);

end