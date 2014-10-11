classdef model_pses
    
    methods(Static = true)
        function name = get_name()
            name = 'PSEs';
        end
        
        function predictions = predict_mu_probe(params, data)
            predictions = data.mp;
        end
        
        function params = solve_params(data)
            params = data.mp;
        end
    end
end
