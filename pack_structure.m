function [structure] = pack_structure(varargin)
% packs all the variables passed as arguments in varargin into a structure,
%  with field names equal to the argument names in the caller

for i=1:length(varargin)
    structure.(inputname(i))=varargin{i};
end
