classdef DataViewer < handle
    
    properties (SetObservable = true)
        Session
        ClusterIdx
        RF
    end
    
    
    properties (Access = protected)
        handles
    end
    
    
    
    methods
        function obj = DataViewer(varargin)
            
        end
        
        
        
        function select_session_updated(obj,src,event)
            
            h = obj.handles;
            
            if isequal(src,'init')
                a = evalin('base','whos'); 
                ind = ismember({a.class},'epa.Session');
                an = {a(ind).name};
                b = cellfun(@(x) evalin('base',x),an,'uni',0);
                h.SelectSession.Object = [b{:}];
            end
            
            cS = h.SelectSession.CurrentObject;
            
            h.SelectCluster.Object = cS.Clusters;
                        
            h.SelectEvent1.Object  = cS.Events;
            if length(cS.Events) > 1
                r = h.SelectEvent2.handle.Layout.Row;
                h.GridNav.RowHeight{r} = 25;
                h.SelectEvent2.Object  = cS.Events;
                h.SelectEvent2.CurrentObject  = cS.Events(2);
            else
                h.GridNav.RowHeight{h.SelectEvent2.handle.Layout.Row} = 0;
            end
        end
        
        function select_event_updated(obj,src,event)
            
        end
        
        function select_cluster_updated(obj,src,event)
            % TESTING
            h = obj.handles;
            cobj = h.SelectCluster.CurrentObject;
            cobj.plot_summary('parent',h.PanelPlots,'event',h.SelectEvent1.CurrentObject);
        end
        
        function create(obj)
            
            f = uifigure;
            obj.handles.Figure = f;
            
            g = uigridlayout(f);            
            g.ColumnWidth = {200, '1x'};
            g.RowHeight   = {'0.2x','0.8x'};
            obj.handles.MainGrid = g;

                        
            gNav = uigridlayout(g);
            gNav.Layout.Row = [1 2];
            gNav.Layout.Column = 1;
            gNav.ColumnWidth = {'1x',25};
            gNav.RowHeight = repmat({25},1,5);
            obj.handles.GridNav = gNav;
            
            gPlots = uigridlayout(g);
            gPlots.Layout.Row = 2;
            gPlots.Layout.Column = 2;
            gPlots.ColumnWidth = {'1x'};
            gPlots.RowHeight = {'1x'};
            obj.handles.GridPlots = gPlots;
            
            
            h = uipanel(gPlots);
            obj.handles.PanelPlots = h;
            
            
            h = epa.ui.SelectObject(gNav,'epa.Session');
            h.handle.Layout.Row = 1;
            h.handle.Layout.Column = 1;
            h.handle.Tooltip = 'Select a Session';
            obj.handles.SelectSession = h;
            
            h = uibutton(gNav);
            h.Layout.Row = 1;
            h.Layout.Column = 2;
            h.Text = '...';
            h.Tooltip = 'Load Session Objects';
            obj.handles.LoadSession = h;
            
            

            
            h = epa.ui.SelectObject(gNav,'epa.Cluster','uilistbox');
            h.handle.Layout.Row = [2 4];
            h.handle.Layout.Column = 1;
            h.handle.Multiselect = 'on';
            h.handle.Tooltip = 'Select a Cluster or Clusters';
            obj.handles.SelectCluster = h;
            
            
            
            
            h = epa.ui.SelectObject(gNav,'epa.Event','uidropdown');
            h.handle.Layout.Row = 5;
            h.handle.Layout.Column = 1;
            h.handle.Tooltip = 'Select Event 1';
            obj.handles.SelectEvent1 = h;
            
            h = epa.ui.SelectObject(gNav,'epa.Event','uidropdown');
            h.handle.Layout.Row = 6;
            h.handle.Layout.Column = 1;
            h.handle.Tooltip = 'Select Event 2';
            obj.handles.SelectEvent2 = h;
            
            
            set(allchild(gNav), ...
                'FontName','Consolas', ...
                'FontSize',12);
            
            
            
            addlistener(obj.handles.SelectSession,'Updated',@obj.select_session_updated);
            addlistener(obj.handles.SelectEvent,  'Updated',@obj.select_event_updated);
            addlistener(obj.handles.SelectCluster,'Updated',@obj.select_cluster_updated);

            
            obj.select_session_updated('init');

        end
    end
    
    
end
