classdef helper < handle
    methods (Static)
        function tok = tokenize(str,delimiters)
            if nargin < 2 || isempty(delimiters), delimiters = ','; end
            tok = textscan(str,'%s',-1,'delimiter',delimiters);
            tok = tok{1};
        end
        
        function par = parse_parameters(par,varargin)
            
            if startsWith(class(par),'epa.plot')
                par = epa.helper.obj2par(par);
            end
            
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
            
            [~,params] = parseparams(varargin);
            for i = 1:2:length(params)
                par.(lower(params{i})) = params{i+1};
            end
        end
        
        function par = obj2par(obj)
            p = properties(obj);
            for i = 1:length(p)
                par.(p{i}) = obj.(p{i});
            end
        end
        
        function par2obj(obj,par)
            m = metaclass(obj);
            p = m.PropertyList;
            ind = [p.Constant] ...
                | [p.Abstract] ...
                | [p.Dependent] ...
                | ismember({p.SetAccess},{'private','protected'});
            p(ind) = [];
            p = {p.Name};
            fn = fieldnames(par);
            p = intersect(p,fn);
            for i = 1:length(p)
                obj.(p{i}) = par.(p{i});
            end
        end
        
        function els = listen_for_props(obj,callbackFcn)
            m = metaclass(obj);
            p = m.PropertyList;
            p(~[p.SetObservable]) = [];
            p = {p.Name};
            els = addlistener(obj,p,'PostSet',callbackFcn);
        end
        
        function cm = colormap(cm,n)
            
            if isempty(cm)
                if n == 1
                    cm = [0 0 0];
                else
                    cm = @lines;
                end
            end
            
            if ischar(cm)
                cm = str2func(cm);
            end
            
            if isa(cm,'function_handle')
                cm = cm(n);
            elseif size(cm,1) == n
                cm = cm(1:n,:);
            end
        end
        
        function setfont(h,sz)
            if nargin < 2 || isempty(sz), sz = 10; end
            fnt = getpref('epa','FontName','Consolas');
            hs = findobj(h,'-property','FontName');
            set(hs,'FontName',fnt,'FontSize',sz);
        end
        
        function t = plot_types
           pt = fullfile(epa.helper.rootdir,'+epa','+plot','@*');
           d = dir(pt);
           d(~[d.isdir]) = [];
           t = {d.name};
           t(ismember(t,'@PlotType')) = [];
           t = cellfun(@(a) a(2:end),t,'uni',0);
        end
        
        function rd = rootdir
            rd = fileparts(fileparts(fileparts(which('epa.helper'))));
        end
        
        
    end
end