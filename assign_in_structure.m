function [structure] = assign_in_structure(varargin, q)
% assigns the variables passed as arguments in varargin into a structure in
% a given position q, with field names equal to the argument names in the
% caller

for i=1:length(varargin)
    structure.(inputname(i))(q)=varargin{i};
end
