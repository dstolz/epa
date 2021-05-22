classdef DataViewer < handle
    
    properties (SetObservable = true)
        Session
        ClusterIdx
        RF
        
        Par
    end
    
    
    properties (Access = protected)
        handles
        ParOut
    end
    
    
    properties (Dependent)
        curEvent1
        curEvent2
        curClusters
        curSession
        curPlotStyle
    end
    
    methods
        function obj = DataViewer()
            obj.create;
        end
        
        function delete(obj)
            if isvalid(obj.handles.Figure), delete(obj.handles.Figure); end
        end
        
        
        function delete_fig(obj,src,event)
            setpref('epa_DataViewer','FigurePosition',obj.handles.Figure.Position);
            delete(obj.handles.Figure);
        end
        
        
        
        function o = get.curSession(obj)
            o = obj.handles.SelectSession.CurrentObject;
        end
        
        
        function o = get.curClusters(obj)
            o = obj.handles.SelectClusters.CurrentObject;
        end
        
        
        function o = get.curEvent1(obj)
            o = obj.handles.SelectEvent1.CurrentObject;
        end
        
        function o = get.curEvent2(obj)
            o = [];
            if length(obj.curSession.Events) > 1
                o = obj.handles.SelectEvent2.CurrentObject;
            end
        end
        
        function s = get.curPlotStyle(obj)
            s = obj.handles.SelectPlotStyle.Value;
        end
        
        
        
        function set.Session(obj,S)
            obj.handles.SelectSession.Object = S;
            obj.select_session_updated('init');
        end
        
        
        function plot(obj,src,event)
            f = figure('Name',obj.curSession.Name,'NumberTitle','off');
            f.Color = 'w';
            
            par = obj.Par;
            par.event = obj.curEvent1;
            par.eventvalue = obj.handles.SelectEvent1Values.Value;
            
            par.parent = f;
            
            obj.Par = par;
            
            obj.ParOut = feval(obj.curPlotStyle,obj.curClusters,par);
        end
        
        
        function create(obj)
            
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

        end
    end
    
    methods (Access = private)
        function create_plotdropdown(obj,src,event)
            %TODO: GENERATE THIS LIST FROM CLUSTER/RF OBJECT METADATA
            plottypes = {'summary','psth','raster'};
            src.Items = plottypes;
            src.ItemsData = cellfun(@(a) str2func(sprintf('plot_%s',a)),plottypes,'uni',0);
            src.Value = @plot_summary;
        end
        
        
        
        function select_session_updated(obj,src,event)
            
            h = obj.handles;
            
            if isequal(src,'init')
                a = evalin('base','whos'); 
                ind = ismember({a.class},'epa.Session');
                
                if isempty(ind) || ~any(ind)
                    return
                end
                
                an = {a(ind).name};
                b = cellfun(@(x) evalin('base',x),an,'uni',0);
                h.SelectSession.Object = [b{:}];
                n = [h.SelectSession.Object.Name];
                % TODO: ADD NAME OF SESSION VARIABLE FROM BASE WORKSPACE
                h.SelectSession.handle.Items = n;
            end
            
            cS = h.SelectSession.CurrentObject;
            
            if isempty(cS)
                h.SelectEvent1.handle.Enable ='off';
                h.SelectEvent2.handle.Enable ='off';
                return
            end
            
            h.SelectClusters.Object = cS.Clusters;
            
            h.SelectEvent1.Object  = cS.Events;
            obj.select_event_updated(h.SelectEvent1);
            
            
            h.SelectSession.handle.Enable = 'on';
            h.SelectClusters.handle.Enable = 'on';
            h.SelectEvent1.handle.Enable ='on';
            h.SelectEvent2.handle.Enable ='on';
            h.SelectEvent1Values.Enable = 'on';
            h.SelectEvent2Values.Enable = 'on';
            
            if length(cS.Events) > 1
                h.SelectEvent2.Object  = cS.Events;
                h.SelectEvent2.CurrentObject  = cS.Events(2);
                obj.select_event_updated(h.SelectEvent2);
            else
                h.SelectEvent2.handle.Enable = 'off';
                h.SelectEvent2Values.Enable = 'off';
            end
        end
        
        function select_event_updated(obj,src,event)
            
            h = obj.handles.(sprintf('%sValues',src.handle.Tag));
            
            dv = src.CurrentObject.DistinctValues;
            dvstr = cellstr(num2str(dv));
            
            h.Items     = dvstr;
            h.ItemsData = dv;
            h.Value     = dv;
                
        end
        
        function select_cluster_updated(obj,src,event)
            % TESTING
            h = obj.handles;
            cobj = h.SelectClusters.CurrentObject;
        end
        
        function process_keys(obj,src,event)
            
        end
        
        
        function plot_style_value_changed(obj,src,event)
            %TODO: UPDATE RELEVANT PARAMETERS. MAYBE WITH CMD LINE ACCESS??
        end
    end
    
end
