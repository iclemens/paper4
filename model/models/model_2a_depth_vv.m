classdef model_2a_depth_vv < base_model

    methods(Access = public)
        
        function obj = model_2a_depth_vv()
            obj.name = 'Depth VV';
            obj.conditions = 1:2;
            obj.param_names = {'Alpha'};
        end


        function predictions = predict_mu_second(~, params, data)            
            params = params / 2;
            
            e1 = data.e1 ./ data.d1;
            e2 = data.e2 ./ data.d2;
            
            a = params .* e1 .* data.d1 + 1;
            b = params .* e2 .* data.d2 + 1;
            
            predictions = (data.m1 .* a) ./ b;            
        end


        function predictions = predict_mu_probe(~, params, data) 
            params = params / 2;
          
            er = data.er ./ data.dr;
            ep = data.ep ./ data.dp;            
            
            a = params .* er .* data.dr + 1;
            b = params .* ep .* data.dp + 1;
            
            predictions = (data.mr .* a) ./ b;
        end


        function params = solve_params(obj, data)
            d = filter_conditions(data, obj.conditions);
            
            phi_r = d.er ./ d.dr;
            phi_p = d.ep ./ d.dp;
            
            Y = d.mp - d.mr;
            X = phi_r .* d.mr .* d.dr - phi_p .* d.mp .* d.dp;
            
            params = (X' \ Y') * 2;
        end

    end
end
