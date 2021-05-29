function create_nav(obj)

if isempty(obj.parent)
    % figure
    fpos = getpref('epa_DataViewer','FigurePosition',[400 250 500 400]);
    f = uifigure('Position',fpos);
    f.DeleteFcn = @obj.delete_fig;
    f.WindowKeyPressFcn = @obj.process_keys;
    movegui(f,'onscreen');
    obj.parent = f;
end


% main grid layout
NavGrid = uigridlayout(obj.parent);
NavGrid.ColumnWidth = {100,100,100,'1x'};
NavGrid.RowHeight   = {25,'1x',25,'1x'};
obj.handles.NavGrid = NavGrid;


% toolbar
TbarGrid = uigridlayout(NavGrid);
TbarGrid.Layout.Column = [1 4];
TbarGrid.Layout.Row    = 1;
TbarGrid.ColumnWidth   = repmat({25},1,5);
TbarGrid.RowHeight     = {'1x'};
TbarGrid.Padding       = [5 0 5 0];
obj.handles.ToolbarGrid = TbarGrid;

h = uibutton(TbarGrid);
h.Icon = fullfile(matlabroot,'toolbox','matlab','icons','foldericon.gif');
h.Tooltip = 'Change data path';
h.Text = '';
h.ButtonPushedFcn = @obj.change_data_path;
obj.handles.LoadSessionButton = h;




% Session listbox
h = epa.ui.SelectObject(NavGrid,'epa.Session','uilistbox');
h.handle.Layout.Column = [1 3];
h.handle.Layout.Row = 2;
h.handle.Tag = 'SelectSession';
h.handle.Multiselect = 'on';
h.handle.Enable = 'off';
h.handle.Tooltip = 'Select a Session';
obj.handles.SelectSession = h;




% Clusters
h = uilabel(NavGrid);
h.Layout.Column = 1;
h.Layout.Row = 3;
h.Text = 'Clusters';

h = epa.ui.SelectObject(NavGrid,'epa.Cluster','uilistbox');
h.handle.Layout.Column = 1;
h.handle.Layout.Row = 4;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectClusters';
h.handle.Multiselect = 'on';
h.handle.Tooltip = 'Select a Cluster or Clusters';
obj.handles.SelectClusters = h;




% Events
h = epa.ui.SelectObject(NavGrid,'epa.Event','uidropdown');
h.handle.Layout.Column = 2;
h.handle.Layout.Row = 3;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectEvent1';
h.handle.Tooltip = 'Select Event 1';
obj.handles.SelectEvent1 = h;

h = epa.ui.SelectObject(NavGrid,'epa.Event','uidropdown');
h.handle.Layout.Column = 3;
h.handle.Layout.Row = 3;
h.handle.Enable = 'off';
h.handle.Tag = 'SelectEvent2';
h.handle.Tooltip = 'Select Event 2';
obj.handles.SelectEvent2 = h;

h = uilistbox(NavGrid);
h.Layout.Column = 2;
h.Layout.Row = 4;
h.Enable = 'off';
h.Tag = 'SelectEvent1Values';
h.Multiselect = 'on';
obj.handles.SelectEvent1Values = h;

h = uilistbox(NavGrid);
h.Layout.Column = 3;
h.Layout.Row = 4;
h.Enable = 'off';
h.Tag = 'SelectEvent2Values';
h.Multiselect = 'on';
obj.handles.SelectEvent2Values = h;





% Plot
PlotGrid = uigridlayout(NavGrid);
PlotGrid.ColumnWidth = {'1x','1x'};
PlotGrid.RowHeight = {25,'1x',25};
PlotGrid.Padding = [0 0 0 0];
PlotGrid.Layout.Column = 4;
PlotGrid.Layout.Row = [2 length(NavGrid.RowHeight)];
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

h = uilistbox(PlotGrid);
h.Layout.Row = 2;
h.Layout.Column = [1 2];
h.ValueChangedFcn = @obj.select_parameter;
obj.handles.ParameterList = h;

h = uieditfield(PlotGrid);
h.Layout.Row = 3;
h.Layout.Column = [1 2];
h.ValueChangedFcn = @obj.parameter_edit;
obj.handles.ParameterEdit = h;


h = obj.handles;

% Set fonts
epa.helper.setfont(obj.parent,12);





addlistener(h.SelectSession, 'Updated',@obj.select_session_updated);
addlistener(h.SelectEvent1,  'Updated',@obj.select_event_updated);
addlistener(h.SelectEvent2,  'Updated',@obj.select_event_updated);
addlistener(h.SelectClusters,'Updated',@obj.select_cluster_updated);


obj.select_session_updated('init');

obj.plot_style_value_changed;