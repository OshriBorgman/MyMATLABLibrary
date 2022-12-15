function [break_curve] = BreakCurvProfData(prof_data, pos)
%BREAKTHROUGH CURVES FROM PROFILE DATA Plot the solute breakthrough curve
%at a given position from the concentration profile data

%   Detailed explanation goes here

% INPUT
% prof_data: the concentration profile data, given as a time series of
% concentration profiles
% pos: the position on the profile to sample, given as an index

% Create the output vector
break_curve = zeros(1, length(prof_data));

for t = 1:length(prof_data)
    break_curve(t) = prof_data{t}(pos);
end

end