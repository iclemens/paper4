classdef model_pses
    
    methods(Static = true)
        function name = get_name()
            name = 'PSEs';
        end
        
        function labels = get_param_names()
          labels = {
            'BW', 'WB', 'FW', 'WF', 'BF', 'FB', 'B NF', 'B FN', 'W NF', 'W FN'
            };
        end
        
        function predictions = predict_mu_probe(params, data)
            predictions = data.mp;
        end
        
        function params = solve_params(data)
            params = data.mp;
        end
    end
end
