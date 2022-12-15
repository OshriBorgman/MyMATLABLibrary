function [centMass, secMom] = SoluteSpatialMoment(F, maxF, minF, porSpc)

%SOLUTE SPATIAL MOMENTS Calculate the spatial moments of solute
%concentration fields

% INPUT
% F: the field variable
% maxF: the maximum value of the variable to be considered in the mixing
% zone
% minF: the minimum value of the variable to be considered in the mixing
% zone
% porSpc: the points comprising the pore space (grains excluded)

% The mixing zone points
mixZone = (F<maxF & F>minF & porSpc);
% mixZone = (F>minF & porSpc);

[X,Y] = meshgrid(1:size(F,2), 1:size(F,1));

% Calculate the position of the center of mass
xCentOfMass = sum(X(mixZone).*F(mixZone))/sum(F(mixZone));
yCentOfMass = sum(Y(mixZone).*F(mixZone))/sum(F(mixZone));

% The second central moment of the solute concentration for the whole plume
xSecCentMom = sum((X(mixZone)-xCentOfMass).^2.*F(mixZone))/sum(F(mixZone));
ySecCentMom = sum((Y(mixZone)-yCentOfMass).^2.*F(mixZone))/sum(F(mixZone));

% % calculate the differences between the x values and the center of mass
% % positions
% xFront = X-xCentOfMass;
% % Exclude the pixels not in the mixing zone pore space (including grains)
% xFront(~mixZone) = 0;
% % Exclude the pixels upstream from the center of mass
% xFront(xFront<0) = 0;
% % Exclude pixels not part of the main cluster
% xFrLabel = bwlabel(xFront);
% xFrProps = regionprops(xFrLabel);
% [M, I] = max([xFrProps.Area]);
% xFront(~(xFrLabel==I)) = 0;
% 
% % calculate the differences between the y values and the center of mass
% % positions
% yFront = Y-yCentOfMass;
% % Exclude the pixels not in the mixing zone pore space (including grains)
% yFront(~mixZone) = 0;
% % Exclude the pixels upstream from the center of mass
% yFront(xFront<0) = 0;
% 
% % Exclude pixels not part of the main cluster
% xFrLabel = bwlabel(xFront);
% xFrProps = regionprops(xFrLabel);
% [M, I] = max([xFrProps.Area]);
% xFront(~(xFrLabel==I)) = 0;
% yFront(~(xFrLabel==I)) = 0;
% 
% % The mass of the solute in the relevant part of the front
% mFront = sum(F(xFront>0));
% % The second central moment of the solute concentration for the part of the
% % solute front downstream from the center of mass
% xSecCentMom = sum(xFront.^2.*(F.*(xFront>0)), "all")/mFront;
% ySecCentMom = sum(yFront.^2.*(F.*(yFront>0)), "all")/mFront;

centMass = [xCentOfMass, yCentOfMass];
secMom = [xSecCentMom, ySecCentMom];

end

