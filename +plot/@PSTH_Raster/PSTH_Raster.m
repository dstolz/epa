classdef PSTH_Raster < handle & dynamicprops
    
    
    properties (SetObservable = true)
        Cluster        (1,1) %epa.Cluster
        
        event           % event name
        eventvalue     (1,:)
        
        binsize        (1,1) double {mustBeNonempty,mustBePositive,mustBeFinite} = 0.01;
        window         (1,2) double {mustBeNonempty,mustBeFinite} = [0 1];
        normalization  (1,:) char {mustBeNonempty,mustBeMember(normalization,{'count','firingrate','countdensity','probability','cumcount','cdf','pdf'})} = 'count';
        showlegend     (1,1) logical {mustBeNonempty} = false;
        showeventonset (1,1) logical {mustBeNonempty} = true;
        
        colormap      = [];
        
        sortevents     (1,:) char {mustBeMember(sortevents,{'original','events'})} = 'original';

        parent
        ax
    end
    
    properties (SetAccess = private)
        handles
        PSTH
        Raster
    end
        
    properties (Constant)
        DataFormat = '1D';
    end
    
    methods
        function obj = PSTH_Raster(Cluster,varargin)
            obj.Cluster = Cluster;
            
            par = epa.helper.parse_parameters(obj,varargin);
            
            p = properties(obj);
            p(ismember(p,'DataFormat')) = [];
            fn = fieldnames(par);
            p = intersect(p,fn);
            for i = 1:length(p)
                obj.(p{i}) = par.(p{i});
            end
            
        end
        
        function set.window(obj,w)
            if numel(w) == 1, w = sort([0 w]); end
            obj.window = w(:)';
        end
        
        
        function plot(obj)
            if isempty(obj.ax), obj.ax = gca; end
            
            par = epa.helper.obj2par(obj);
            par = rmfield(par,{'Cluster','DataFormat'});
            fn  = fieldnames(par);
            
            obj.ax.Visible = 'off';
            
            t = tiledlayout(obj.ax.Parent,10,1);
            t.Padding = 'none';
            t.TileSpacing = 'none';
            
            if isa(obj.ax.Parent,'matlab.graphics.layout.TiledChartLayout')
                t.Layout.Tile = obj.ax.Layout.Tile;
                t.Layout.TileSpan = obj.ax.Layout.TileSpan;
            end
                        
            axR = nexttile(t);
            axR.Layout.Tile = 1;
            axR.Layout.TileSpan = [3 1];
            par.ax = axR;
            parv = struct2cell(par);
            parv = [fn parv]';
            obj.Raster = epa.plot.Raster(obj.Cluster,parv{:});
            obj.Raster.plot;
            axR.Color = 'none';
            axR.XAxis.Color = 'none';
            axR.XAxis.Label.String = 'none';
            axR.YAxis.Color = 'none';
            axR.YAxis.Label.String = 'none';
            
            axP = nexttile(t);
            axP.Layout.Tile = 3;
            axP.Layout.TileSpan = [7 1];
            par.ax = axP;
            parv = struct2cell(par);
            parv = [fn parv]';
            obj.PSTH = epa.plot.PSTH(obj.Cluster,parv{:});
            obj.PSTH.plot;
            axP.Color = 'none';
            axP.Title.String = '';
            
            t.Toolbar = axtoolbar;
            
            linkaxes([axR axP],'x');
            
        end
        
    end
    
end