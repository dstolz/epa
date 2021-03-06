classdef Cluster < handle & dynamicprops
    % C = epa.Cluster(ID)
    % C = epa.Cluster(ID,epa.Spike)
    % C = epa.Cluster(id,samples,[waveforms])
    
    
    properties
        ID       (1,1) uint16 {mustBeFinite}
        Name     string
        Type     string {mustBeMember(Type,["SU","MSU","MU","Noise",""])} = ""

        SpikeTimes (:,1) double {mustBeFinite}
        Waveforms  single
        
        Channel  (1,1) double {mustBeFinite,mustBeInteger} = -1;
        Shank    (1,1) double {mustBePositive,mustBeFinite,mustBeInteger} = 1;
        Coords   (1,3) double {mustBeFinite} = [0 0 0];
        
        Note     (:,1) string   % User notes
        
        TitleStr (1,1) string   % auto generated if empty
    end
    
    
    properties (Dependent)
        SamplingRate   % same as obj.Session.SamplingRate
        SpikeSamples   % array of spike samples
        N              % spike count
    end
    
    properties (SetAccess = immutable)
        Session      (1,1) %epa.Session
    end
    
    
    methods
        [t,eidx,vid] = eventlocked(obj,varargin)
        [c,b,v] = psth(obj,varargin)
        
        
        function obj = Cluster(SessionObj,ID,SpikeTimes,SpikeWaveforms)
            narginchk(2,4)
            
            obj.Session = SessionObj;
            obj.ID = ID;
            
            
            if nargin == 3
                obj.SpikeTimes = SpikeTimes;
                
            elseif nargin == 4
                
                obj.Waveforms = SpikeWaveforms;
            end
        end
        
        function t = get.SpikeSamples(obj)
            t = round(obj.SpikeTimes .* obj.SamplingRate);
        end
        
        
        function n = get.N(obj)
            n = length(obj.SpikeTimes);
        end
        
        function fs = get.SamplingRate(obj)
            fs = obj.Session.SamplingRate;
        end
        
        function tstr = get.TitleStr(obj)
            if obj.TitleStr == ""
                tstr = sprintf('%s[%d]',obj.Type,obj.ID);
                if obj.Name ~= ""
                    tstr = sprintf('%s-%s',obj.Name,tstr);
                end
            else
                tstr = obj.TitleStr;
            end
        end
    end
end
                
                
