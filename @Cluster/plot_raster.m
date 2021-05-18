function par = plot_raster(obj,varargin)
% par = obj.plot_raster(par)
% par = obj.plot_raster('Name',Values, ...)
% 
% 
% 
% event         ... either an epa.Event object or a string of the event name
% colormap      ... function handle to determine colors, default = @lines
% eventvalue    ... specify event value(s) or 'all', default = 'all'
% window        ... [1x2] window relative to event onset in seconds, or
%                   [1x1] window duration, default = 1
% sort          ... Determines how trials should be sorted. 'original' or
%                   'events'. 'events' orders the trials by event value.
% ax            ... handle for axes to plot in. Default = gca
% showlegend    ... true/false, default = true
% showeventonset... true/false, default = true




% defaults
par.ax          = [];
par.binsize     = 1e-3;
par.colormap    = [];
par.window      = [0 1];
par.showlegend  = true;
par.showeventonset = true;
par.sort        = 'original';
par.tiledlayout = [];

par = epa.helper.parse_parameters(par,varargin);
mustBeNonempty(par.event);

if numel(obj) > 1
    t = tiledlayout('flow');
    par.tiledlayout = t;
    par = arrayfun(@(a) a.plot_raster(par),obj);
    t.Title.String = obj(1).Session.Name;
    return
end

if ~isempty(par.tiledlayout)
    par.ax = nexttile(par.tiledlayout);
end







if ~isa(par.event,'epa.Event')
    par.event = obj.Session.find_Event(par.event);
end




[t,eidx,v] = obj.eventlocked(par);







E = par.event; % copy handle to Event object

if isempty(par.ax), par.ax = gca; end

cla(par.ax,'reset');

if isempty(eidx)
    fprintf(2,'No data found for event "%s" in cluster "%s"\n',E.Name,obj.Name)
    return
end

uv = unique(v);




cm = epa.helper.colormap(par.colormap,numel(uv));

% TODO: OPTION TO SHADE BEHIND SPIKES BASED ON EVENT

if par.showeventonset
    par.ploteventonset = line(par.ax,[0 0],[0 max(eidx)+1],'color',[0.6 0.6 0.6],'linewidth',1,'tag','ZeroMarker');
end

for i = 1:length(uv)
    ind = uv(i) == v;
    par.plot(i) = line(par.ax,t(ind),eidx(ind),'color',cm(i,:), ...
        'linestyle','none','marker','.', ...
        'markersize',2,'markerfacecolor',cm(i,:), ...
        'DisplayName',sprintf('%g%s',uv(i),E.Units), ...
        'Tag',sprintf('%s_%s = %g%s',obj.TitleStr,E.Name,uv(i),E.Units));
end


par.ax.XLim = par.window;
par.ax.YLim = [min(eidx)-1 max(eidx)+1];

par.ax.XAxis.TickDirection = 'out';
par.ax.YAxis.TickDirection = 'out';

if par.showlegend
    legend(par.plot,'location','EastOutside');
end

switch lower(par.sort)
    case 'original'
        ylabel(par.ax,'trial');
    case 'events'
        ylabel(par.ax,'by event');
end


xlabel(par.ax,'time (s)');

title(par.ax,sprintf('Cluster %d - %s',obj.ID,E.Name));

box(par.ax,'on');


if nargout == 0, clear par; end

% uncertain why, but this needs to be at the end to work properly
drawnow
set(par.plot.MarkerHandle,'Style','vbar');








