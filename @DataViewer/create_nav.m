function create_nav(obj)

fpos = getpref('epa_DataViewer','FigurePosition',[400 250 400 420]);
f = uifigure('Position',fpos);
f.DeleteFcn = @obj.delete_fig;
f.WindowKeyPressFcn = @obj.process_keys;
movegui(f,'onscreen');
obj.handles.Figure = f;

g = uigridlayout(f);
g.ColumnWidth = {'1x','1x','1x'};
g.RowHeight   = [repmat({25},1,8),{'1x'}];
obj.handles.NavGrid = g;


h = epa.ui.SelectObject(g,'epa.Session','uilistbox');
h.handle.Layout.Column = [1 3];
h.handle.Layout.Row = [1 3];
h.handle.Tag = 'SelectSession';
h.handle.Multiselect = 'on';
h.handle.Enable = 'off';
h.handle.Tooltip = 'Select a Session';
obj.handles.SelectSession = h;

h = uilabel(g);
h.Text = 'Clusters';

h = epa.ui.SelectObject(g,'epa.Cluster','uilistbox');
h.handle.Layout.Column = 1;
h.handle.Layout.Row = [5 8];
h.handle.Enable = 'off';
h.handle.Tag = 'SelectClusters';
h.handle.Multiselect = 'on';
h.handle.Tooltip = 'Select a Cluster or Clusters';
obj.handles.SelectClusters = h;









h = epa.ui.SelectObject(g,'epa.Event','uidropdown');
h.handle.Layout.Column = 2;
h.handle.Layout.Row = 4;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectEvent1';
h.handle.Tooltip = 'Select Event 1';
obj.handles.SelectEvent1 = h;

h = epa.ui.SelectObject(g,'epa.Event','uidropdown');
h.handle.Layout.Column = 3;
h.handle.Layout.Row = 4;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectEvent2';
h.handle.Tooltip = 'Select Event 2';
obj.handles.SelectEvent2 = h;

h = uilistbox(g);
h.Layout.Column = 2;
h.Layout.Row = [5 8];
h.Enable = 'off';
h.Tag = 'SelectEvent1Values';
h.Multiselect = 'on';
obj.handles.SelectEvent1Values = h;

h = uilistbox(g);
h.Layout.Column = 3;
h.Layout.Row = [5 8];
h.Enable = 'off';
h.Tag = 'SelectEvent2Values';
h.Multiselect = 'on';
obj.handles.SelectEvent2Values = h;



PlotGrid = uigridlayout(g);
PlotGrid.ColumnWidth = repmat({'1x'},1,3);
PlotGrid.RowHeight = repmat({25},1,3);
PlotGrid.Layout.Column = [1 2];
PlotGrid.Layout.Row = length(g.RowHeight);
obj.handles.PlotGrid = PlotGrid;

h = uidropdown(PlotGrid,'CreateFcn',@obj.create_plotdropdown);
h.Layout.Column = [1 2];
h.Layout.Row = 2;
h.ValueChangedFcn = @obj.plot_style_value_changed;
obj.handles.SelectPlotStyle = h;

h = uibutton(PlotGrid);
h.Layout.Column = 3;
h.Layout.Row = 3;
h.Text = 'Plot';
h.ButtonPushedFcn = @obj.plot;


h = findobj(g,'-property','FontName');
set(h, ...
    'FontName','Consolas', ...
    'FontSize',12);


h = obj.handles;
addlistener(h.SelectSession,'Updated',@obj.select_session_updated);
addlistener(h.SelectEvent1, 'Updated',@obj.select_event_updated);
addlistener(h.SelectEvent2, 'Updated',@obj.select_event_updated);
addlistener(h.SelectClusters,'Updated',@obj.select_cluster_updated);


obj.select_session_updated('init');

