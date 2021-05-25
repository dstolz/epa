function create_nav(obj)

% figure
fpos = getpref('epa_DataViewer','FigurePosition',[400 250 500 300]);
f = uifigure('Position',fpos);
f.DeleteFcn = @obj.delete_fig;
f.WindowKeyPressFcn = @obj.process_keys;
movegui(f,'onscreen');
obj.handles.Figure = f;



% main grid layout
g = uigridlayout(f);
g.ColumnWidth = {100,100,100,'1x'};
g.RowHeight   = {75,25,125};
obj.handles.NavGrid = g;

% Session listbox
h = epa.ui.SelectObject(g,'epa.Session','uilistbox');
h.handle.Layout.Column = [1 3];
h.handle.Layout.Row = 1;
h.handle.Tag = 'SelectSession';
h.handle.Multiselect = 'on';
h.handle.Enable = 'off';
h.handle.Tooltip = 'Select a Session';
obj.handles.SelectSession = h;




% Clusters
h = uilabel(g);
h.Layout.Column = 1;
h.Layout.Row = 2;
h.Text = 'Clusters';

h = epa.ui.SelectObject(g,'epa.Cluster','uilistbox');
h.handle.Layout.Column = 1;
h.handle.Layout.Row = 3;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectClusters';
h.handle.Multiselect = 'on';
h.handle.Tooltip = 'Select a Cluster or Clusters';
obj.handles.SelectClusters = h;




% Events
h = epa.ui.SelectObject(g,'epa.Event','uidropdown');
h.handle.Layout.Column = 2;
h.handle.Layout.Row = 2;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectEvent1';
h.handle.Tooltip = 'Select Event 1';
obj.handles.SelectEvent1 = h;

h = epa.ui.SelectObject(g,'epa.Event','uidropdown');
h.handle.Layout.Column = 3;
h.handle.Layout.Row = 2;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectEvent2';
h.handle.Tooltip = 'Select Event 2';
obj.handles.SelectEvent2 = h;

h = uilistbox(g);
h.Layout.Column = 2;
h.Layout.Row = 3;
h.Enable = 'off';
h.Tag = 'SelectEvent1Values';
h.Multiselect = 'on';
obj.handles.SelectEvent1Values = h;

h = uilistbox(g);
h.Layout.Column = 3;
h.Layout.Row = 3;
h.Enable = 'off';
h.Tag = 'SelectEvent2Values';
h.Multiselect = 'on';
obj.handles.SelectEvent2Values = h;





% Plot
PlotGrid = uigridlayout(g);
PlotGrid.ColumnWidth = {'1x','1x'};
PlotGrid.RowHeight = {25,'1x'};
PlotGrid.Padding = [0 0 0 0];
PlotGrid.Layout.Column = 4;
PlotGrid.Layout.Row = [1 length(g.RowHeight)];
obj.handles.PlotGrid = PlotGrid;

h = uidropdown(PlotGrid,'CreateFcn',@obj.create_plotdropdown);
h.Layout.Row = 1;
h.Layout.Column = 1;
h.ValueChangedFcn = @obj.plot_style_value_changed;
obj.handles.SelectPlotStyle = h;

h = uibutton(PlotGrid);
h.Layout.Row = 1;
h.Layout.Column = 2;
h.Text = 'Plot';
h.ButtonPushedFcn = @obj.plot;

h = uitree(PlotGrid);
h.Layout.Row = 2;
h.Layout.Column = [1 2];
obj.handles.ParameterTree = h;



h = obj.handles;

% Set fonts
epa.helper.setfont(h.Figure,12);





addlistener(h.SelectSession, 'Updated',@obj.select_session_updated);
addlistener(h.SelectEvent1,  'Updated',@obj.select_event_updated);
addlistener(h.SelectEvent2,  'Updated',@obj.select_event_updated);
addlistener(h.SelectClusters,'Updated',@obj.select_cluster_updated);


obj.select_session_updated('init');

