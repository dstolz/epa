classdef DataViewer < handle
    
    properties (SetObservable = true)
        Session
        Par
    end
    
    
    properties (Access = protected)
        handles
    end
    
    
    properties (Dependent)
        curEvent1
        curEvent2
        curClusters
        curSession
        curPlotStyle
    end
    
    methods
        create_nav(obj);
        plot(obj,src,event);
        
        function obj = DataViewer()
            obj.create_nav;
        end
        
        function delete(obj)
            if isvalid(obj.handles.Figure), delete(obj.handles.Figure); end
        end
        
        
        function delete_fig(obj,src,event)
            setpref('epa_DataViewer','FigurePosition',obj.handles.Figure.Position);
            delete(obj.handles.Figure);
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
        
        
        function o = get.curSession(obj)
            o = obj.handles.SelectSession.CurrentObject;
        end
        
        function set.Session(obj,S)
            obj.handles.SelectSession.Object = S;
            obj.select_session_updated('init');
        end
        
        
        
        
        
        
        
        
        
        
        
    end
    
    methods (Access = private)
        function create_plotdropdown(obj,src,event)
            plottypes = epa.helper.plot_types;
            src.Items     = plottypes;
            src.ItemsData = plottypes;
            src.Value     = 'PSTH';
        end
        
        
        
        function select_session_updated(obj,src,event)
            
            h = obj.handles;
            
            if isequal(src,'init')
                a = evalin('base','whos'); 
                ind = ismember({a.class},'epa.Session');
                
                if isempty(ind) || ~any(ind)
                    return
                end
                
                an = string({a(ind).name});
                b = cellfun(@(x) evalin('base',x),an,'uni',0);
                % add index values to Session array; there must be a
                % simpler way to do this...
                ann = string([]);
                for i = 1:length(b)
                    for j = 1:numel(b{i})
                        ann(end+1) = sprintf('[%s(%d)] %s',an(i),j,b{i}(j).Name);
                    end
                end
                h.SelectSession.Object = [b{:}];
                h.SelectSession.handle.Items = ann;
            end
            
            S = h.SelectSession.CurrentObject;
            
            if isempty(S)
                h.SelectEvent1.handle.Enable ='off';
                h.SelectEvent2.handle.Enable ='off';
                return
            end
            
            
            
            h.SelectSession.handle.Enable  = 'on';
            h.SelectClusters.handle.Enable = 'on';
            h.SelectEvent1.handle.Enable   = 'on';
            h.SelectEvent2.handle.Enable   = 'on';
            h.SelectEvent1Values.Enable    = 'on';
            h.SelectEvent2Values.Enable    = 'on';
            
            
            C = S.common_Clusters;
            E = S.common_Events;
            
            
            if isempty(C)
                h.SelectClusters.handle.Enable = 'off';
                uialert(h.Figure,'No Clusters were found to be in common across the selected Sessions.', ...
                    'No Clusters','Icon','warning','Modal',true);
                return
            end
            
            if isempty(E)
                h.SelectEvent1.handle.Enable   = 'off';
                h.SelectEvent2.handle.Enable   = 'off';
                h.SelectEvent1Values.Enable    = 'off';
                h.SelectEvent2Values.Enable    = 'off';
                uialert(h.Figure,'No Events were found to be in common across the selected Sessions.', ...
                    'No Events','Icon','warning','Modal',true);
                return
            end
                
                
            
            h.SelectClusters.Object = C;
            h.SelectEvent1.Object   = E;
            
            
            
            obj.select_event_updated(h.SelectEvent1);
            if length(E) > 1
                h.SelectEvent2.Object  = E;
                h.SelectEvent2.CurrentObject = E(2);
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
            
        end
        
        function process_keys(obj,src,event)
            
        end
        
        
        function plot_style_value_changed(obj,src,event)
            %TODO: UPDATE RELEVANT PARAMETERS. MAYBE WITH CMD LINE ACCESS??
            % *** MAKE PLOT FUNCTIONS THEIR OWN CLASSES ***
%             h = obj.handles;
%             switch h.SelectPlotStyle.String
%                 case 'raster'
%                     
%                 case 'psth'
                    
        end
    end
    
end
