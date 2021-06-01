classdef PlotType < handle & dynamicprops
    
    properties (Abstract,Constant)
        DataFormat
        Style
    end
    
    methods (Abstract)
        plot(obj,src,event)
    end
    
    
    
    
    properties (SetObservable,AbortSet)
        Cluster        (1,1) %epa.Cluster
        colormap      = [];
        
        showtitle       (1,1) logical = true
        titleposition   (1,:) double {mustBeFinite,mustBeNonempty,mustBeNonNan} = [0 1.02 0];
        title
        titlefontsize   (1,1) double {mustBePositive,mustBeFinite,mustBeNonempty} = 10;
        
        showinfo        (1,1) logical = true
        infoposition    (1,:) double {mustBeFinite,mustBeNonempty,mustBeNonNan} = [1 1.02 0];
        info
        infofontsize   (1,1) double {mustBePositive,mustBeFinite,mustBeNonempty} = 10;
    end
    
    properties
        listenforchanges (1,1) logical = true
    end
    
    
    properties (Transient) % immutable???
        ax
    end
    
    properties (Access = protected,Hidden,Transient)
        els
    end
    
    properties (SetAccess = protected,Transient)
        handles
    end
    
    
    methods
        function obj = PlotType(varargin)
            par = epa.helper.parse_parameters(obj,varargin);
            
            epa.helper.par2obj(obj,par);
            
            obj.els = epa.helper.listen_for_props(obj,@obj.plot);
        end
        
        function set.listenforchanges(obj,tf)
            obj.listenforchanges = tf;
            obj.els.Enabled = tf;
        end
        
        function show_infotext(obj)
            if ~isfield(obj.handles,'info') || isempty(obj.handles.info) || ~isvalid(obj.handles.info)
                obj.handles.info = text(obj.ax);
            end
            t = obj.handles.info;
            t.String = obj.info;
            t.LineStyle = 'none';
            t.FontSize = obj.infofontsize;
            t.FontName = 'Consolas';
            t.Units = 'normalized';
            t.HorizontalAlignment = 'right';
            t.Position = obj.infoposition;
            obj.handles.info = t;
        end
        
        
        function s = get.info(obj)
            if isequal(obj.Cluster,0)
                s = {''};
            else
                s = sprintf('%s %d',obj.Cluster.TitleStr,obj.Cluster.N);
            end
        end
        
        function axes_destroyed(obj,src,event)
            delete(obj.els);
        end
        
        
        function show_title(obj,str)
            if ~isfield(obj.handles,'title') || isempty(obj.handles.title) || ~isvalid(obj.handles.title)
                obj.handles.title = text(obj.ax);
            end
            t = obj.handles.title;
            t.LineStyle = 'none';
            t.FontSize = obj.titlefontsize;
            t.FontName = 'Consolas';
            t.Units = 'normalized';
            t.HorizontalAlignment = 'left';
            t.Position = obj.titleposition;
            obj.handles.title = t;
            
            if nargin < 2 || isempty(str) 
                t.String = obj.title;
            else
                t.String = str;
            end
        end
        
        
        function s = get.title(obj)
            if isequal(obj.Cluster,0)
                s = {''};
            else
                s = {obj.Cluster.Session.Name};
            end
        end
        
        function standard_plot_postamble(obj)
            if obj.showtitle, obj.show_title; end
            if obj.showinfo, obj.show_infotext; end
            if obj.showlegend, obj.handles.legend = legend([obj.handles.plot]); end

            epa.helper.setfont(obj.ax);

            obj.ax.Color = 'none';
        end
        
        
        
        function par = saveobj(obj)
            par = epa.helper.obj2par(obj);
            
            % dump any transient properties
            m = metaclass(obj);
            p = m.PropertyList;
            p(~[p.Transient]) = [];
            p = {p.Name};
            idx = find(ismember(p,fieldnames(par)));
            for i = 1:length(idx)
                par.(p{idx(i)}) = [];
            end
        end
        
        
    end % methods (Access = public)
      
    methods (Access = protected)
        
        function setup_plot(obj)
            if isempty(obj.ax) || ~ishandle(obj.ax) || ~isvalid(obj.ax)
                obj.ax = gca; 
            end
            % not sure why, but ax.DeleteFcn is not being called when the
            % axes object is destroyed ????????
            obj.ax.DeleteFcn = @obj.axes_destroyed;
        end
    end % methods (Access = protected)
    
    methods (Static)
        function obj = loadobj(par)
            obj = epa.plot.(par.Style)(par.Cluster,par);
        end
    end
end