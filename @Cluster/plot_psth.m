function h = plot_psth(obj,varargin)
% h = plot_psth(ClusterObj,['Name',Values])
% 
% event         ... either an epa.Event object or a string of the event name
% eventvalue    ... specify event value(s) or 'all', default = 'all'
% binsize       ... scalar value in seconds, default = 0.01
% window        ... [1x2] window relative to event onset in seconds, or
%                   [1x1] window duration, default = [0 0.5]
% normalization ... Determines how the histogram should be normalized,
%                   values: 'count','firingrate','max'
%                   default = 'count'
% showlegend    ... true/false, default = true



% defaults
par.binsize       = 0.01;
par.window        = [0 0.5];
par.colormap      = @lines;
par.normalization = 'count';
par.showlegend    = false;
par.ax = [];

par = epa.helper.parse_parameters(par,varargin);

mustBeNonempty(par.event);

if ~isa(par.event,'epa.Event')
    par.event = obj.Session.find_event(par.event);
end

E = par.event; % copy handle to Event object


if isempty(par.ax), par.ax = gca; end

cla(par.ax,'reset');


mustBeNonempty(par.event);

if ~isa(par.event,'epa.Event')
    par.event = obj.Session.find_event(par.event);
end

E = par.event; % copy handle to Event object



if numel(par.window) == 1
    par.window = sort([0 par.window]);
end
par.window = par.window(:)';


[c,b,uv] = obj.psth(par);



cm = colormap(par.colormap(length(uv)));


switch lower(par.normalization)
    case {'firingrate','fr'}
        c = c ./ par.binsize;
    case 'count'
    case 'max'
        c = c ./ max(c);
end % otherwise just use counts

cla(par.ax);
hold(par.ax,'on')
for i = 1:size(c,1)
    par.plot.path(i) = histogram(par.ax,'BinEdges',b,'BinCounts',c(i,:),'FaceColor',cm(i,:), ...
        'EdgeColor','none','EdgeAlpha',0.6, ...
        'DisplayName',sprintf('%s = %g%s',E.Name,uv(i),E.Units), ...
        'Tag',sprintf('%s = %g%s',E.Name,uv(i),E.Units));
end
hold(par.ax,'off')



par.plot.eventonset = line(par.ax,[0 0],par.ax.YLim,'color',[0.6 0.6 0.6],'linewidth',1,'tag','ZeroMarker');
uistack(par.plot.eventonset,'bottom');


xlabel(par.ax,'time (s)');

switch lower(par.normalization)
    case {'firingrate','fr'}
        ylabel(par.ax,'firing rate (Hz)');
    case 'count'
        ylabel(par.ax,'count');
    case 'max'
        ylabel(par.ax,'normalized to max');
end
        

title(par.ax,sprintf('Cluster %d - %s',obj.ID,E.Name));

par.ax.XLim = par.window;
box(par.ax,'on');

if par.showlegend, legend(par.plot.path); end

if nargout == 0, clear par; end







