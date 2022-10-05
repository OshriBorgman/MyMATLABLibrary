function [fieldvars] = unpack_in_caller(varargin)
% ancillary function for pseudonamespacing: receives structures, creates
%  one variable in the caller for each field of each structure

for j=1:length(varargin)
    if isstruct(varargin{j})
        fieldvars=fieldnames(varargin{j});
        for i=1:length(fieldvars)
            assignin('caller',fieldvars{i},varargin{j}.(fieldvars{i}));
        end
    end
end