function [Dm] = CalcDiffCoeff(w_g)
%CALCULATE DIFFUSION COEFFICIENT Summary of this function goes here
%   The diffusion coefficient is calculated according to D'errico et al. 2004

% moles of water in 1 kg mixture
n_wat = (1-w_g)/18e-3;
% moles of glycerol in 1 kg mixture
n_gl = w_g/92.1e-3;
% The glycerol mole fraction
x_gl = n_gl/(n_gl+n_wat);
% The diffusion coefficient of Fluorescein in m^2/s
Dm = (1.024-0.91*x_gl)/(1+7.5*x_gl)*1e-9;
% Dm = 1.049e-8; %[m^2 s^-1


end

