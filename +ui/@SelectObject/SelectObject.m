classdef SelectObject < handle
   
    
    properties (SetAccess = immutable)
        handle
        parent
        style   (1,:) char {mustBeMember(style,{'uidropdown','uilistbox'})} = 'uidropdown';
    end
    
    properties (SetObservable = true)
        Object
        
    end
    
    properties (SetAccess = protected)
        ObjectClass (1,:) char
    end
    
    properties (Dependent)
        CurrentObject
    end
    
    properties (Access = private, Hidden)
        els
    end
    
    
    events
        Updated
        % els = addlistener(h,'Updated',@(~,~) disp('Updated!'))
    end
    
    
    methods
        function obj = SelectObject(parent,Object,style)
            narginchk(1,3)
            
            obj.parent = parent;
            
            if nargin == 3, obj.style = style; end
            
            obj.handle = obj.create;

            obj.els = addlistener(obj,'Object','PostSet',@obj.refresh);
            
            if nargin >= 2
                if ischar(Object) || isstring(Object)
                    obj.ObjectClass = char(Object);
                else
                    obj.ObjectClass = class(Object);
                    obj.Object = Object;
                end
            end
        end
        
        
        function cobj = get.CurrentObject(obj)
            cobj = obj.handle.Value;
        end
        
        function set.CurrentObject(obj,cobj)
            obj.handle.Value = cobj;
        end
    end
    
    
    methods (Access = protected)
        
        function delete(obj)
            delete(obj.els);
        end
        
        function value_changed(obj,src,evnt)
            notify(obj,'Updated',evnt);
        end
        
        function [v,o] = AvailableVars(obj)
            v = [];
            if isa(obj.Object,obj.ObjectClass)
                [v,idx] = sort([obj.Object.Name]);
                o = obj.Object(idx);
            end
        end
        
        function refresh(obj,src,event)
            [v,o] = obj.AvailableVars;
            
            if isempty(v), v = ""; end
            
            obj.handle.Items = v;
            obj.handle.ItemsData = o;
            obj.handle.Value = o(1);
        end
        
        function h = create(obj)
            h = feval(obj.style,obj.parent);
            if isprop(h,'Editable'), h.Editable = false; end
            h.ValueChangedFcn = @obj.value_changed;
            h.Items = "";
            h.ItemsData = "";
            h.Value = "";
            h.UserData = obj;
        end
    end
    
end