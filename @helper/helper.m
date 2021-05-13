classdef helper < handle
    methods (Static)
        function tok = tokenize(str,delimiters)
            if nargin < 2 || isempty(delimiters), delimiters = ','; end
            tok = textscan(str,'%s',-1,'delimiter',delimiters);
            tok = tok{1};
        end
        
        function par = parse_parameters(par,varargin)
            if length(varargin) == 1
                if iscell(varargin) && numel(varargin{1}) == 1
                    varargin = varargin{1};
                end
                
                % assume already config structure
                if isstruct(varargin{1})
                    fn = fieldnames(varargin{1});
                    fv = struct2cell(varargin{1});
                    varargin = [fn'; fv'];
                    varargin = varargin(:)';
                    
                elseif iscell(varargin)
                    % might be passed as a varargin, instead of varargin{:}
                    varargin = varargin{:};
                end
            end
            
            
            [r,params] = parseparams(varargin);
            for i = 1:2:length(params)
                par.(lower(params{i})) = params{i+1};
            end
        end
    end
end