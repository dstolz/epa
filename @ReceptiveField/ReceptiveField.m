classdef ReceptiveField < handle
    
    properties
        
    end
       
    properties (SetObservable = true)
        metric      (1,:) char {mustBeMember(metric,{'sum','mean','median','mode'})} = 'mean';
        window      (1,2) double {mustBeFinite} = [0 1];
        plotstyle   (1,:) char {mustBeMember(plotstyle,{'surf','imagesc','contourf','contour'})} = 'contour';
        colormap = parula;
    end
    
    
    properties (SetAccess = protected)
        ax
    end
    
    properties (Dependent)
        data
        windowSamples
        
        xValues
        yValues
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
            x = obj.Events(1).DistinctValues;
        end
        
        function y = get.yValues(obj)
            y = obj.Events(2).DistinctValues;
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
                        
            ev_y = obj.Events(1).Values; uev_y = unique(ev_y);
            ev_x = obj.Events(2).Values; uev_x = unique(ev_x);
            d = zeros(length(uev_y),length(uev_x));
            for i = 1:length(uev_y)
                for j = 1:length(uev_x)
                    ind = ev_y == uev_y(i) & ev_x == uev_x(j);
                    d(i,j) = feval(obj.metric,sc(ind));
                end
            end
        end
        
        function h = plot(obj,ax)
            if nargin == 2, obj.ax = ax; end
            h = obj.(['plot_' obj.plotstyle]);
            
            if nargout == 0, clear h; end
        end
        
        function h = plot_contour(obj,ax)
            if nargin < 2, ax = gca; end            
            
            [my,mx] = meshgrid(obj.yValues,obj.xValues);
            h = contour(ax,my,mx,obj.data);
            ax.Colormap = obj.colormap;
        end
        
        
        function h = plot_contourf(obj,ax)
            if nargin < 2, ax = gca; end            
            
            [my,mx] = meshgrid(obj.yValues,obj.xValues);
            h = contourf(ax,my,mx,obj.data);
            ax.Colormap = obj.colormap;
        end
        
        function h = plot_surf(obj,ax)
            if nargin < 2, ax = gca; end            
            h = surf(ax,obj.yValues,obj.xValues,obj.data);
        end
        
        function h = plot_imagesc(obj,ax)
            if nargin < 2, ax = gca; end            
            h = imagesc(ax,obj.yValues,obj.xValues,obj.data);
            ax.YDir = 'normal';
        end
        
    end
    
end