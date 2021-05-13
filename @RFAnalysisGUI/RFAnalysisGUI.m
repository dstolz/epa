classdef RFAnalysisGUI < handle
    
    properties (SetObservable = true)
        Cluster
        Events
    end
    
    properties (SetAccess = protected)
        figure
        rfAxes
    end
    
    methods
        function obj = RFAnalysisGUI(Cluster,Events)
            
        end
        
        
        function create(obj)
            obj.figure = uifigure('Name',obj.Cluster.TitleStr);
            
            
        end
        
    end
    
    
    
end