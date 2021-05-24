function par = plot_psth(obj,varargin)
% par = plot_psth(ClusterObj,['Name',Values])
% 
% event         ... either an epa.Event object or a string of the event name
% eventvalue    ... specify event value(s) or 'all', default = 'all'
% binsize       ... scalar value in seconds, default = 0.01
% window        ... [1x2] window relative to event onset in seconds, or
%                   [1x1] window duration, default = [0 0.5]
% normalization ... Determines how the histogram should be normalized:
%                   'count','firingrate','countdensity','probability','cumcount','cdf','pdf'
%                   default = 'count' (note that 'firingrate' is equivalent to 'countdensity')
% showlegend    ... true/false, default = true




% defaults
par.binsize       = 0.01;
par.window        = [0 1];
par.colormap      = [];
par.normalization = 'count';
par.showlegend    = false;
par.showeventonset= true;
par.ax = [];
par.tiledlayout = [];

par = epa.helper.parse_parameters(par,varargin);

if numel(obj) > 1
    t = tiledlayout('flow');
    par.tiledlayout = t;
    par = arrayfun(@(a) a.plot_psth(par),obj);
    t.Title.String = obj(1).Session.Name;
    return
end


if ~isempty(par.tiledlayout) && isvalid(par.tiledlayout)
    par.ax = nexttile(par.tiledlayout);
end

if isempty(par.ax), par.ax = gca; end

cla(par.ax,'reset');

mustBeNonempty(par.event);

if ~isa(par.event,'epa.Event')
    par.event = obj.Session.find_Event(par.event);
end

E = par.event; % copy handle to Event object



if numel(par.window) == 1
    par.window = sort([0 par.window]);
end
par.window = par.window(:)';


[c,b,uv] = obj.psth(par);




cm = epa.helper.colormap(par.colormap,size(c,1));


cla(par.ax,'reset');
hold(par.ax,'on')

if par.showeventonset
    par.ploteventonset = line(par.ax,[0 0],[0 max(c(:))*1.1],'color',[0.6 0.6 0.6],'linewidth',1,'tag','ZeroMarker');
end

for i = 1:size(c,1)
    par.plot.path(i) = histogram(par.ax, ...
        'BinEdges',b, ...
        'BinCounts',c(i,:), ...
        'FaceColor',cm(i,:), ...
        'EdgeColor','none', ...
        'EdgeAlpha',0.6, ...
        'FaceAlpha',0.8, ...
        'DisplayName',sprintf('%s = %g%s',E.Name,uv(i),E.Units), ...
        'Tag',sprintf('%s = %g%s',E.Name,uv(i),E.Units));
end
hold(par.ax,'off')


xlabel(par.ax,'time (s)');

switch lower(par.normalization)
    case {'firingrate','fr'}
        ylabel(par.ax,'firing rate (Hz)');
    otherwise
        ylabel(par.ax,par.normalization);
end
        

title(par.ax,{obj.Session.Name,sprintf('%s [%s] - %s',obj.Name,obj.Type,E.Name)});

par.ax.XLim = par.window;
% box(par.ax,'on');

par.ax.XAxis.TickDirection = 'out';
par.ax.YAxis.TickDirection = 'out';

axis(par.ax,'tight');

if par.showlegend, legend(par.plot.path); end

epa.helper.setfont(par.ax);

if nargout == 0, clear par; end







