classdef PSTH < handle & dynamicprops
    
    
    properties (SetObservable = true)
        Cluster        (1,1) %epa.Cluster
        
        event           % event name
        eventvalue     (1,:)
        
        binsize        (1,1) double {mustBePositive,mustBeFinite} = 0.01;
        window         (1,2) double {mustBeFinite} = [0 1];
        normalization  (1,:) char {mustBeMember(normalization,{'count','firingrate','countdensity','probability','cumcount','cdf','pdf'})} = 'count';
        showlegend     (1,1) logical = false;
        showeventonset (1,1) logical = true;
        
        colormap      = [];
        
        
        parent
        ax
    end
    
    properties (SetAccess = private)
        handles
    end
        
    methods
        function obj = PSTH(Cluster,varargin)
            obj.Cluster = Cluster;
            
            par = epa.helper.parse_parameters(obj,varargin);
            
            p = properties(obj);
            fn = fieldnames(par);
            p = intersect(p,fn);
            for i = 1:length(p)
                obj.(p{i}) = par.(p{i});
            end
            
            if isempty(obj.ax), obj.ax = gca; end
        end
        
        function set.window(obj,w)
            if numel(w) == 1, w = sort([0 w]); end
            obj.window = w(:)';
        end
        
        
        function plot(obj)
            
            axe = obj.ax;
            
            S = obj.Cluster.Session;
            C = obj.Cluster;
            
            
            cla(axe,'reset');
            
                        
            if ~isa(obj.event,'epa.Event')
                obj.event = S.find_Event(obj.event);
            end
            
            E = obj.event;

            par = epa.helper.obj2par(obj);
            [c,b,uv] = C.psth(par);
            
            
            cm = epa.helper.colormap(par.colormap,size(c,1));
            
            
            cla(axe,'reset');
            hold(axe,'on')
            
            if par.showeventonset
                par.handles.eventonset = line(axe,[0 0],[0 max(c(:))*1.1],'color',[0.6 0.6 0.6],'linewidth',1,'tag','ZeroMarker');
            end
            
            for i = 1:size(c,1)
                par.handles.plot(i) = histogram(axe, ...
                    'BinEdges',b, ...
                    'BinCounts',c(i,:), ...
                    'FaceColor',cm(i,:), ...
                    'EdgeColor','none', ...
                    'EdgeAlpha',0.6, ...
                    'FaceAlpha',1, ...
                    'DisplayName',sprintf('%s = %g%s',E.Name,uv(i),E.Units), ...
                    'Tag',sprintf('%s = %g%s',E.Name,uv(i),E.Units));
            end
            hold(axe,'off')
            
            if size(c,1) > 1
                set([par.handles.plot],'FaceAlpha',0.7);
            end
            
            xlabel(axe,'time (s)');
            
            switch lower(par.normalization)
                case {'firingrate','fr'}
                    ylabel(axe,'firing rate (Hz)');
                otherwise
                    ylabel(axe,par.normalization);
            end
            
            
            title(axe,{S.Name,sprintf('%s [%s] - %s',C.Name,C.Type,E.Name)});
            
            axe.XLim = par.window;
            % box(axe,'on');
            
            axe.XAxis.TickDirection = 'out';
            axe.YAxis.TickDirection = 'out';
            
            axis(axe,'tight');
            
            if par.showlegend, legend(par.plot.path); end
            
            epa.helper.setfont(axe);            
        end
        
        
    end
    
end