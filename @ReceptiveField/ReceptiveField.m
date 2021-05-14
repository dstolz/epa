classdef ReceptiveField < handle
    
    properties
        
    end
       
    properties (SetObservable = true)
        metric      (1,:) char {mustBeMember(metric,{'sum','mean','median','mode'})} = 'mean';
        window      (1,2) double {mustBeFinite} = [0 1];
        plotstyle   (1,:) char {mustBeMember(plotstyle,{'surf','imagesc','contourf','contour'})} = 'contour';
        colormap = @parula;
        
        smoothmethod (1,:) char
    end
    
    
    properties (SetAccess = protected)
        ax
    end
    
    properties (Dependent)
        data
        windowSamples
        
        xValues
        yValues
        
        xEvent
        yEvent
    end
    
    properties (SetAccess = immutable)
        Cluster
        Events
    end
    
    methods
        function obj = ReceptiveField(ClusterObj,EventObj)
            obj.Cluster = ClusterObj;
            
            obj.Events = EventObj;
            
        end
        
        
        
        
        function x = get.xValues(obj)
            x = obj.xEvent.DistinctValues;
        end
        
        function y = get.yValues(obj)
            y = obj.yEvent.DistinctValues;
        end
        
        function xe = get.xEvent(obj)
            xe = obj.Events(1);
        end
        
        function ye = get.yEvent(obj)
            ye = obj.Events(2);
        end
        
        function s = get.windowSamples(obj)
            s = round(obj.Cluster.SamplingRate.*obj.window);
        end
        
        
        function d = get.data(obj)
            ons = obj.Events(1).OnOffSamples(:,1);
            ons = ons+obj.windowSamples;
            
            ss = obj.Cluster.SpikeSamples;
            sc = zeros(size(ons,1),1);
            for i = 1:size(ons,1)
                ind = ss >= ons(i,1) & ss < ons(i,2);
                sc(i) = sum(ind);
            end
                        
            ev_y = obj.yEvent.Values; uev_y = obj.yValues;
            ev_x = obj.xEvent.Values; uev_x = obj.xValues;
            d = zeros(length(uev_y),length(uev_x));
            for i = 1:length(uev_y)
                for j = 1:length(uev_x)
                    ind = ev_y == uev_y(i) & ev_x == uev_x(j);
                    d(i,j) = feval(obj.metric,sc(ind));
                end
            end
            
            [m,n] = size(d);
            switch obj.smoothmethod
                case 'interpft'
                    d = interpft(d,3*m,1);
                    d = interpft(d,3*n,2);
            end
        end
        
        
        
        function h = plot(obj,ax)
            if nargin < 2, ax = gca; end
            obj.ax = ax;
            
            h = obj.(['plot_' obj.plotstyle]);
            
            obj.label_axes;
            
            axis(ax,'tight');
            
            if nargout == 0, clear h; end
            
        end
        
        function h = plot_contour(obj,ax)
            if nargin < 2, ax = gca; end            
            
            [mx,my] = meshgrid(obj.xValues,obj.yValues);
            h = contour(ax,my,mx,obj.data);
            ax.Colormap = obj.colormap;
        end
        
        
        function h = plot_contourf(obj,ax)
            if nargin < 2, ax = gca; end            
            
            [mx,my] = meshgrid(obj.xValues,obj.yValues);
            h = contourf(ax,my,mx,obj.data);
            ax.Colormap = obj.colormap;
        end
        
        function h = plot_surf(obj,ax)
            if nargin < 2, ax = gca; end            
            h = surf(ax,obj.xValues,obj.yValues,obj.data);
        end
        
        function h = plot_imagesc(obj,ax)
            if nargin < 2, ax = gca; end            
            h = imagesc(ax,obj.xValues,obj.yValues,obj.data);
            ax.YDir = 'normal';
        end
        
    end
   
    methods (Access = protected)
        function label_axes(obj)
            ax = obj.ax;
            
            ax.XAxis.Label.Interpreter = 'none';
            ax.YAxis.Label.Interpreter = 'none';
            ax.XAxis.Label.String = obj.xEvent.Name;
            ax.YAxis.Label.String = obj.yEvent.Name;
            
            ax.Title.Interpreter = 'none';
            ax.Title.String = obj.Cluster.TitleStr;
        end
    end
end