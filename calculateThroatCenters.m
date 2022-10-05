function [xThr, yThr] = calculateThroatCenters(x_1, y_1, x_2, y_2, d)

% CALCULATE THROAT CENTERS from the data on the location of the confining
% grains (segment ends) and their diameter

% INPUT
% x_1: the x-position of the first grain center
% y_1: the y-position of the first grain center
% x_2: the x-position of the second grain center
% y_2: the y-position of the second grain center
% d: the diameter of the confining grains

% Calculate the delta x and y
deltax = x_2-x_1;
deltay = y_2-y_1;
% Calculate the base angle alpha
alpha = atan(deltay./deltax);
% Calculate the position of the intersection between the connecting line
% and the perimeter of the first grain
deltax_star_1 = d(:,1)./2.*cos(alpha);
x_star_1 = x_1+deltax_star_1;
deltay_star_1 = d(:,1)./2.*sin(alpha);
y_star_1 = y_1+deltay_star_1;
% Calculate the position of the intersection between the connecting line
% and the perimeter of the second grain
deltax_star_2 = d(:,2)./2.*cos(alpha);
x_star_2 = x_2-deltax_star_2;
deltay_star_2 = d(:,2)./2.*sin(alpha);
y_star_2 = y_2-deltay_star_2;
% The two pairs [(x_star_1, y_star_1) (x_star_2, y_star_2)] represent the
% end points of the throat. Then, the middle point is calculated as
xThr = x_star_1+(x_star_2-x_star_1)./2;
yThr = y_star_1+(y_star_2-y_star_1)./2;

end
