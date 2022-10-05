function [x1, x2] = SolveQuad(coeff)
%SOLVE QUADRATIC EQUATION 

c = coeff{1};
b = coeff{2};
a = coeff{3};
x1 = (-b + sqrt(b.*b - 4.*a.*c))./(2.*a);
x2 = (-b - sqrt(b.*b - 4.*a.*c))./(2.*a);

end

