function fieldvars = unpack_in_caller_temp(varargin)
% ancillary function for pseudonamespacing: receives structures, creates
%  one variable in the caller for each field of each structure

n = 0;
for j=1:length(varargin)
    if isstruct(varargin{j})
        fieldvars=fieldnames(varargin{j});
        for i=1:length(fieldvars)
            n = n+1;
            assignin('caller',[fieldvars{i} 'Temp'],varargin{j}.(fieldvars{i}));
%             varargout{n} = [fieldvars{i} 'Temp'];
        end
    end
end