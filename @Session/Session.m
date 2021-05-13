classdef Session < handle
    
    properties
        Clusters (1,:) epa.Cluster  % An array of Cluster objects
        Events   (1,:) epa.Event    % An array of Event objects
        
        Name     (1,1) string = "NO NAME" % Session name
        Date     (1,1) string       % Session date
        Time     (1,1) string       % Session start time
        
        Researcher (1,1) string
        
        SamplingRate  (1,1) double {mustBePositive,mustBeFinite}  = 1; % Acquisition sampling rate (Hz)

        Notes     (:,1) string      % User notes
        
        UserData    % whatever you want
    end
    
    properties (Dependent)
        EventNames
        NClusters
        NEvents
        DistinctEventValues
    end
    
    methods
        
        function obj = Session(SamplingRate,Clusters,Events)
            if nargin >= 1 && ~isempty(SamplingRate), obj.SamplingRate = SamplingRate; end
            if nargin >= 2 && isa(Clusters,'epa.Cluster'), obj.Clusters = Clusters; end
            if nargin >= 3 && isa(Events,'epa.Event'), obj.Events = Events; end
            
        end
        
        function add_Event(obj,varargin)
            existingEvents = [obj.Events.Name];
            
            if isa(varargin{1},'epa.Event')
                en = varargin{1}.Name;
            else
                en = varargin{1};
            end
            
            if any(ismember(existingEvents,en))
                fprintf(2,'Event "%s" already eaxists for this Session object\n',en)
                return
            end
            
            obj.Events(end+1) = epa.Event(obj,varargin{:});
        end
        
        function add_Cluster(obj,varargin)
            existingIDs = [obj.Clusters.ID];
            
            if isa(varargin{1},'epa.Cluster')
                cid = varargin{1}.ID;
            else
                cid = varargin{1};
            end
            
            assert(~ismember(cid,existingIDs),'epa:Session:add_Cluster:IDexists', ...
                'Cluster %s already exists for this Session object\n',cid)            
            
            obj.Clusters(end+1) = epa.Cluster(obj,varargin{:});
        end
        
       
        
        function e = find_event(obj,name)
            if ischar(name), name = string(name); end
            if iscellstr(name), name = cellfun(@string,name); end
            
            e = obj.Events(strcmpi([obj.Events.Name],name));
        end
        
        
        function v = get.DistinctEventValues(obj)
            v = arrayfun(@(a) a.DistinctValues,obj.Events,'uni',0);
        end
        
        function n = get.EventNames(obj)
            n = [obj.Events.Name];
        end
        
        function n = get.NClusters(obj)
            n = numel(obj.Clusters);
        end
        
        function n = get.NEvents(obj)
            n = numel(obj.Events);
        end
    end
    
end