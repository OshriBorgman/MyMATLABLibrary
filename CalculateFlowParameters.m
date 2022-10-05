% The weight fraction of glycerol in water
w_g = 0.2;
% The temperature in deg. C
T = 20;
% The viscosity of glycerol-water mixture [kg*m^-1*s^-1]
[rho_s, mu_s] = densityViscosityWaterGlycerolSolution(w_g, T);

% % The viscosity, surface tension and density are calculated according to Takamura et al. 2012 https://doi.org/10.1016/j.petrol.2012.09.003.
% % The density of glycerol at 20 degrees C
% rho_gl = 1261; % kg/m^3
% % The density of water at 20 degrees C
% rho_w = 998; % kg/m^3
% % The density calculated by Eq. 3
% rho_s = (1-w_g)*rho_w + w_g*rho_gl;

% % The diffusion coefficient is calculated according to D'errico et al. 2004, , where  is the mole fraction of the glycerol
% moles of water in 1 kg mixture
n_wat = (1-w_g)/18e-3;
% moles of glycerol in 1 kg mixture
n_gl = w_g/92.1e-3;
% The glycerol mole fraction
x_gl = n_gl/(n_gl+n_wat);
% The diffusion coefficient of Fluorescein in m^2/s
Dm = (1.024-0.91*x_gl)/(1+7.5*x_gl)*1e-9;
% Dm = 1.049e-8; %[m^2 s^-1

% The average throat size in m, calculated from the analysis of the sample
% design
wAvg = lengthScale;
% Pore space aperture (pillar height)
b = 1e-3; % [m]

% The cross-section area of the cell
ACC = b*cellWidth;
% The average pore velocity [m/sec]
vLiq = Qliq/(ACC*phi);

% The Peclet number (CHECK THE UNITS OF THE THROAT WIDTHS!!!)
Pe = wAvg*vLiq/Dm;

% The Reynolds number over a pillar diameter (CHECK THE UNITS OF THE GRAIN DIAMETERS!!!)
Re = rho_s*vLiq*mean(Ro*pixLen)/mu_s;

% % Calculate Ca for the co-injection phase
% Capillary number is calculated according to  (Jimenez-Martinez et al. 2017)
% The surface tension for 20% w/w glycerol at 20 degrees, according to Takamura et al. 2012 https://doi.org/10.1016/j.petrol.2012.09.003.
gammaGlWatAir = 0.0717; % [N/m]