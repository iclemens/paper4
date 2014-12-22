classdef model_1b_no_depth_voma < base_model

    methods(Access = public)
        
        function obj = model_1b_no_depth_voma()
            obj.name = 'No Depth V1-a';
            obj.conditions = 1:2;
            obj.param_names = {'Alpha'};
        end
        
        
        function predictions = predict_mu_second(~, params, data)            
            params = params / 2;
            
            a = params * data.e1 ./ data.d1 + (1 - params);
            b = params * data.e2 ./ data.d2 + (1 - params);
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        
        function predictions = predict_mu_probe(~, params, data) 
            params = params / 2;
          
            a = params * data.er ./ data.dr + (1 - params);
            b = params * data.ep ./ data.dp + (1 - params);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        
        function params = solve_params(obj, data)
            d = filter_conditions(data, obj.conditions);
            
            phi_r = d.er ./ d.dr;
            phi_p = d.ep ./ d.dp;
            
            Y = d.mp - d.mr;
            X = phi_r .* d.mr - phi_p .* d.mp + d.mp - d.mr;
            
            params = (X' \ Y') * 2;
        end

    end
end
