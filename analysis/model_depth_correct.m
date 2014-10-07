classdef model_depth_correct

    methods(Static = true)
        function name = get_name()
            name = 'DepthCorrected';
        end
        
        function predictions = predict_mu_second(params, data)            
            a = params * data.e1 + (1 - params);
            b = params * data.e2 + (1 - params);
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        function predictions = predict_mu_probe(params, data)           
            a = params * data.er + (1 - params);
            b = params * data.ep + (1 - params);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(d_p3, ~)
            fit_conditions = 1:4;

            er = d_p3.er(fit_conditions);
            ep = d_p3.ep(fit_conditions);
        
            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            Y = mp - mr;
            X = er .* mr - ep .* mp + mp - mr;
            
            params = X' \ Y';
        end

    end

end