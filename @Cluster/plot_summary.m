function par = plot_summary(obj,varargin)



% defaults
par.parent = [];
par.window = [0 1];
par.showlegend = false;
par.tiledlayout = [];

par = epa.helper.parse_parameters(par,varargin);

mustBeNonempty(par.event);



fn = fieldnames(par)';
for f = fn
    cf = char(f);
    [par.raster.(cf),par.psth.(cf)] = deal(par.(cf));
end

if isempty(par.parent), par.parent = figure; end




if numel(obj) > 1
    par = rmfield(par,'tiledlayout');
    n = numel(obj);
    origunits = par.parent.Units;
    par.parent.Units = 'normalized';
    spc = 0.01;
    x = spc./2; xd = 1./n-spc;
    y = 0.05;   yd = 1-y;
    clo(par.parent);
    for i = 1:numel(obj)
        tmppar = par;
        tmppar.parent = uipanel(par.parent,'Position',[x y xd yd], ...
            'BorderType','none','BackgroundColor',par.parent.Color);
        outpar(i) = obj(i).plot_summary(tmppar);
        x = x + xd + spc;
    end
    par.parent.Units = origunits;
    par = outpar;
    return
end


if ~isempty(par.tiledlayout) && isvalid(par.tiledlayout)
    par.parent = nexttile(par.tiledlayout);
end



% setup layout
t = tiledlayout(par.parent,5,1,'TileSpacing','none','Padding','compact');
par.tiledlayout = t;



% plot raster
par.raster.ax = nexttile(t,1,[2 1]);
par.raster = obj.plot_raster(par.raster);
ax = par.raster.ax;
ax.Title.String = '';
ax.XAxis.Label.String = [];
ax.XAxis.Color = 'none';
box(ax,'off');

% plot psth
par.psth.ax = nexttile(t,3,[3 1]);
par.psth = obj.plot_psth(par.psth);
ax = par.psth.ax;
ax.Title.String = '';
ax.XAxis.Label.String = [];
box(ax,'off');

linkaxes([par.raster.ax, par.psth.ax],'x');

t.Title.String    = obj.TitleStr;
t.Title.FontName  = 'Consolas';
t.Title.FontSize  = 10;
t.XLabel.String   = 'time (s)';
t.XLabel.FontName = 'Consolas';
t.XLabel.FontSize = 8;


