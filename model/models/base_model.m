classdef base_model < handle
    
    properties
        conditions = 1:2;
        name = '';
        param_names = {'Alpha'};
    end
    
    
    methods(Access = public)
        
        function name = get_name(obj)            
            if obj.compare_range(obj.conditions, 1:2)
                suffix = 'BW';
            elseif obj.compare_range(obj.conditions, 1:10)
                suffix = 'ALL';
            elseif obj.compare_range(obj.conditions, 7:10)
                suffix = 'NF';
            elseif obj.compare_range(obj.conditions, 1:6)
                suffix = 'BWN';
            end
            
            name = [obj.name ' ' suffix];
        end

        
        function labels = get_param_names(obj)
            labels = obj.param_names;
        end        
        
        
        function set_conditions(obj, conditions)
            obj.conditions = conditions;
        end                
        
        
        function out = compare_range(~, one, two)
            if numel(one) ~= numel(two)
                out = 0;
            elseif all(sort(one) == sort(two))
                out = 1;
            else
                out = 0;
            end
        end
        
    end
    
end