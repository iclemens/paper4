classdef model_1a_no_depth_vv < base_model
    
    methods(Access = public)

        function obj = model_1a_no_depth_vv()
            obj.name = 'No Depth VV';
            obj.conditions = 1:2;
            obj.param_names = {'Alpha'};
        end
                
        
        function predictions = predict_mu_second(~, params, data)            
            params = params / 2;
            
            a = params * data.e1 ./ data.d1 + 1;
            b = params * data.e2 ./ data.d2 + 1;
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        
        function predictions = predict_mu_probe(~, params, data) 
            params = params / 2;
          
            a = params * data.er ./ data.dr + 1;
            b = params * data.ep ./ data.dp + 1;
            
            predictions = (data.mr .* a) ./ b;
        end
        
        
        function params = solve_params(obj, data)
            d = filter_conditions(data, obj.conditions);
            
            phi_r = d.er ./ d.dr;
            phi_p = d.ep ./ d.dp;
            
            Y = d.mp - d.mr;
            X = phi_r .* d.mr - phi_p .* d.mp;           

            params = (X' \ Y') * 2;
        end

    end
end
