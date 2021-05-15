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
        
        function create(obj)
            
            f = uifigure;
            obj.handles.Figure = f;
            
            g = uigridlayout(f);            
            g.ColumnWidth = {200, 120, '1x'};
            g.RowHeight   = {'1x'};
            obj.handles.MainGrid = g;

                        
            gLeft = uigridlayout(g);
            gLeft.ColumnWidth = {'.8x','.2x'};
            gLeft.RowHeight = {25};
            obj.handles.LeftGrid = gLeft;
            
            h = epa.ui.SelectVariable(gLeft,'epa.Session');
            h.handle.Layout.Row = 1;
            h.handle.Layout.Column = 1;
            h.handle.Tooltip = 'Sepcify a Session object variable';
            obj.handles.SelectVariable = h;
            
            h = uibutton(gLeft);
            h.Layout.Row = 1;
            h.Layout.Column = 2;
            h.Text = 'o';
            h.Tooltip = 'Refresh list of Session Objects';
            h.ButtonPushedFcn = @(src,event) refresh(obj.handles.SelectVariable);
            obj.handles.RefresthSelectVariable = h;
            
            
            
            
            
            set(allchild(gLeft), ...
                'FontName','Helvetica', ...
                'FontSize',16);

        end
    end
    
end
