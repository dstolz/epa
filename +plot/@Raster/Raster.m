classdef Raster < handle & dynamicprops
    
    properties (SetObservable = true)
        Cluster        (1,1) %epa.Cluster
        
        event           % event name
        eventvalue     (1,:)
        
        window         (1,2) double {mustBeFinite} = [0 1];
        
        showlegend     (1,1) logical = false;
        showeventonset (1,1) logical = true;
        
        sortevents     (1,:) char {mustBeMember(sortevents,{'original','events'})} = 'original';
        
        colormap      = [];
        
        parent
        ax
    end
    
    properties (SetAccess = private)
        handles
    end
    
    properties (Constant)
        DataFormat = '1D';
    end
    
    methods
        function obj = Raster(Cluster,varargin)
            obj.Cluster = Cluster;
            
            par = epa.helper.parse_parameters(obj,varargin);
            
            epa.helper.par2obj(obj,par);
            
        end
        
        function set.window(obj,w)
            if numel(w) == 1, w = sortevents([0 w]); end
            obj.window = w(:)';
        end
        
        function plot(obj)
            if isempty(obj.ax), obj.ax = gca; end
            
            axe = obj.ax;
            
            S = obj.Cluster.Session;
            C = obj.Cluster;
            
            
            cla(axe,'reset');
            
                        
            if ~isa(obj.event,'epa.Event')
                obj.event = S.find_Event(obj.event);
            end
            
            E = obj.event;

            par = epa.helper.obj2par(obj);
            
            [t,eidx,v] = C.eventlocked(par);
            
            
            if isempty(eidx)
                fprintf(2,'No data found for event "%s" in cluster "%s"\n',E.Name,obj.Name)
                return
            end
            
            uv = unique(v);
            
            
            cm = epa.helper.colormap(par.colormap,numel(uv));
            
            % TODO: OPTION TO SHADE BEHIND SPIKES BASED ON EVENT
            
            if par.showeventonset
                par.handles.eventonset = line(axe,[0 0],[0 max(eidx)+1],'color',[0.6 0.6 0.6],'linewidth',1,'tag','ZeroMarker');
            end
            
            if isfield(par,'plot'), par = rmfield(par,'plot'); end
            for i = 1:length(uv)
                ind = uv(i) == v;
                obj.handles.raster(i) = line(axe,t(ind),eidx(ind),'color',cm(i,:), ...
                    'linestyle','none','marker','.', ...
                    'markersize',2,'markerfacecolor',cm(i,:), ...
                    'DisplayName',sprintf('%g%s',uv(i),E.Units), ...
                    'Tag',sprintf('%s_%s = %g%s',C.TitleStr,E.Name,uv(i),E.Units));
            end
            
            
            axe.XLim = par.window;
            axe.YLim = [min(eidx)-1 max(eidx)+1];
            
            axe.XAxis.TickDirection = 'out';
            axe.YAxis.TickDirection = 'out';
            
            if par.showlegend
                legend([par.handles.raster],'location','EastOutside');
            end
            
            switch lower(par.sortevents)
                case 'original'
                    ylabel(axe,'trial');
                case 'events'
                    ylabel(axe,'by event');
            end
            
            
            xlabel(axe,'time (s)');
            
            title(axe,{S.Name,sprintf('%s [%s] - %s',C.Name,C.Type,E.Name)});
            
            % box(axe,'on');
            
            epa.helper.setfont(axe);
            
            % uncertain why, but this needs to be at the end to work properly
            drawnow
            set([obj.handles.raster.MarkerHandle],'Style','vbar');
            
        end
    end
end