function [pixDist] = clusterPerimDist(imgProps, imgLabel)

% % CLUSTER PERIMETER DISTANCE Calculate the distances between cluster
% perimeters in a binary image

% Run over all clusters
pixDist = zeros(length(imgProps), 1);
for p = 1:length(imgProps)
    %     Find the perimeter pixels
    perimPix = bwperim(imgLabel==p);
    [perimPixLocY, perimPixLocX] = find(perimPix);
    pixDistPoint = zeros(length(perimPixLocX), 1);
    %     Find the other pixels
    restPix = bwperim(logical(imgLabel)-(imgLabel==p));
    [restPixLocY, restPixLocX] = find(restPix);
    %     Find the distance between the perimeter of cluster p and the others
    for q = 1:length(perimPixLocY)
        %         find the shortest distance between point q and the rest
        pixDistPoint(q) = min(sqrt((perimPixLocX(q)-restPixLocX).^2 + ...
            (perimPixLocY(q)-restPixLocY).^2));
    end
    %     Find the minimum distance for each cluster
    pixDist(p) = min(pixDistPoint);
end
