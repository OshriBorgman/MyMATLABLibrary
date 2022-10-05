function [distMap, distMapSkel, distSkel] = SkelFromDistMap(M, filtLen)
%SKELETON FROM DISTANCE MAP Skeletonize using a distance map of a binary
%image

%   INPUT
% M: The input binary image
% filtLen: the length of the window used to filter the image and reduce
% noise

% Calculate the distance map
distMap = imfilter(bwdist(M), ones(filtLen)./filtLen^2);
% skeletonize the distance map
distMapSkel = bwskel(logical(distMap));
% The distances on the skeleton
distSkel = distMap.*distMapSkel;

end

