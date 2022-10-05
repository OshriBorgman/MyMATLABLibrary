function [SaveVars, Pe, Re, Ca] = CalcFlowNonDimNum(wAvg, meanPoreDiam, vLiq, Dm, ...
    SampleDataStruct, rho_s, mu_s, Qliq, gammaGlWatAir, crossSecArea, phi)

%CALCULATE FLOW NON-DIMENSIONAL NUMBERS Summary of this function goes here
%   Detailed explanation goes here

% The Peclet number
Pe = (wAvg)^2*vLiq/(Dm*meanPoreDiam);

% The Reynolds number over a pillar diameter (convert grain diameters from
% mm to m)
Re = rho_s*vLiq*mean(SampleDataStruct.DGrains*1e-3)/mu_s;
% Calculate Ca for the co-injection phase
% Capillary number is calculated according to  (Jimenez-Martinez et al. 2017)

% Calculate the capillary number
Ca = (mu_s*Qliq*wAvg^2)/(gammaGlWatAir*SampleDataStruct.permeablAbs*meanPoreDiam*...
    crossSecArea*phi);

% % Save data:
% The capillary number
SaveVars.CapNum = Ca;
% The Reynolds number
SaveVars.ReyNum = Re;
% The Peclet numbet
SaveVars.PecNum = Pe;

end

