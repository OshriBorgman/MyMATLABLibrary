function [B, fitresult] = FitPolySurfImg(b)

%FIT A POLYNOMIAL SURFACE TO IMAGE Fit a 2-D, 2-order polynomial to an
%image to blur it and reveal the variation in background intensity

% Fit a polynomial surface to blur the image and obtain the background
[X Y] = meshgrid(1:size(b,2), 1:size(b,1));
[fitresult, ~] = createFit(X, Y, b);

% Evaluate the fitted polynomial on the mesh
B = feval(fitresult, X, Y);

end

