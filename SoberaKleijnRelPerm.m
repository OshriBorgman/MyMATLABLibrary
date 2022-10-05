function [k, kRel] = SoberaKleijnRelPerm(dr, dGrains, c)

% SOBERA AND KLEIJN RELATIVE PERMEABILITY Calculate the relative
% permeability of a 2-D porous media of disks according to according to Eq.
% 37 in Sobera and Kleijn PRE 2006
% (https://link.aps.org/doi/10.1103/PhysRevE.74.036301):
% 'delta' is the throat half-length
% 'alpha' is the ratio between standard deviation of the throat half-length
% and the mean half-length
% 'epsilon' is the ratio between mean throat half-length and the overal
% cross-section length of the pore unit (grain+throat)
% 'c' is a constant which I will consider as 1 as default.

% INPUT
% dr: the throat aperture lengths
% Dg: the grain diameters
% c: the equation constant, 1 by default.

if nargin<3
% The equation constant
c = 1;
end

% The throat half-length
delta = dr/2;

% The equation parameters
alphaVar = std(delta)/mean(delta);
epsiVar = mean(delta)/(mean(delta)+mean(dGrains/2));

% The absolute permeability in dimension of L^2
k = c*mean(delta.^2)*(0.5*alphaVar^2+epsiVar);

% The permeability relative to the grain diameter
kRel = k/(mean(dGrains))^2;

end

