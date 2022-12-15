function [match_point_i, match_point_x, match_point_y] = ProfPos...
    (prof_curve_x, prof_curve_y, point_val)
%PROFILE POSITION Find a point on a profile curve
%   Find a point with a value that matches the input value on a
%   longitudinal profile curve 

% INPUT:
% prof_curve_x: the x-values of the profile curve
% prof_curve_y: the y-values of the profile curve
% point_val: the value to match on the curve

% OUTPUT:
% match_point_x: the x-position of the curve point closest to the input
% value
% match_point_y: curve point value closest to the input value

[~, match_point_i] = min(abs(point_val-prof_curve_y));

match_point_y = prof_curve_y(match_point_i);
match_point_x = prof_curve_x(match_point_i);

end