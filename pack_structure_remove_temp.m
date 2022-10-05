function [structure] = pack_structure_remove_temp(varargin)
% packs all the variables passed as arguments in varargin into a structure,
%  with field names equal to the argument names in the caller without the
%  added 'temp'

for i=1:length(varargin)
    newVarName = inputname(i);
    structure.(newVarName(1:end-4)) = varargin{i};
end
