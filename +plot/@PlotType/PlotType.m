classdef PlotType < handle & dynamicprops
    
    properties (Abstract,Constant)
        DataFormat
    end
    
    methods (Abstract)
        plot(obj,src,event)
    end
    
    
    
    
    properties (SetObservable,AbortSet)
        Cluster        (1,1) %epa.Cluster
        colormap      = [];
        showinfo        (1,1) logical = true
        infoposition    (1,:) double {mustBeFinite,mustBeNonempty,mustBeNonNan} = [1 1.02 0];
        info
    end
    
    properties
        listenforchanges (1,1) logical = true
    end
    
    
    properties % immutable???
        ax
    end
    
    properties (Access = protected,Hidden,Transient)
        els
    end
    
    properties (SetAccess = protected)
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
            t.FontSize = 8;
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
        
        
        function set_title(obj,str)
            if nargin < 2 || isempty(str) 
                obj.ax.Title.String = {obj.Cluster.Session.Name};
            else
                obj.ax.Title.String = str;
            end
        end
        
        function standard_post_plot(obj)
                        
            if obj.showlegend, legend([obj.handles.plot]); end

            obj.set_title;
            
            epa.helper.setfont(obj.ax);
            
            if obj.showinfo, obj.show_infotext; end
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
end