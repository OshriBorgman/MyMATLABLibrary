function [centMass, secMom] = SoluteSpatialMoment2(F, subRegion)

%SOLUTE SPATIAL MOMENTS 2 Calculate the spatial moments of solute
%concentration fields, with different variables

% INPUT
% F: the field variable
% subRegion: the part of the field on which to do the calculations

[X,Y] = meshgrid(1:size(F,2), 1:size(F,1));

% Calculate the position of the center of mass
xCentOfMass = sum(X(subRegion).*F(subRegion))/sum(F(subRegion));
yCentOfMass = sum(Y(subRegion).*F(subRegion))/sum(F(subRegion));

% The second central moment of the solute concentration for the whole plume
xSecCentMom = sum((X(subRegion)-xCentOfMass).^2.*F(subRegion))/sum(F(subRegion));
ySecCentMom = sum((Y(subRegion)-yCentOfMass).^2.*F(subRegion))/sum(F(subRegion));

centMass = [xCentOfMass, yCentOfMass];
secMom = [xSecCentMom, ySecCentMom];

end

