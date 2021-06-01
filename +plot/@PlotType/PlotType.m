classdef PlotType < handle & dynamicprops
    
    properties (Abstract,Constant)
        DataFormat
    end
    
    methods (Abstract)
        plot(obj,src,event)
    end
    
    
    
    
    properties (SetObservable)
        showinfo
        infolocation
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
        
        
        
        
        function axes_destroyed(obj,src,event)
            delete(obj.els);
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