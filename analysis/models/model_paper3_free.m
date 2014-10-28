classdef model_paper3_free

    methods(Static = true)
        function name = get_name()
            name = 'Paper3_Free';
        end
        
        function labels = get_param_names()
          labels = {
            'Alpha'
            };
        end        
        
        function predictions = predict_mu_second(params, data)
            params = params / 2;
            
            a = params * data.e1 ./ data.d1 + (1 - params);
            b = params * data.e2 ./ data.d2 + (1 - params);
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        function predictions = predict_mu_probe(params, data)
            params = params / 2;
            
            a = params * data.er ./ data.dr + (1 - params);
            b = params * data.ep ./ data.dp + (1 - params);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(d_p3, ~)
            if any(numel(d_p3.er) == [6 10])
                fit_conditions = 3:6;
            elseif any(numel(d_p3.er) == [12 20])
                fit_conditions = 5:12;
            end            

            er = d_p3.er(fit_conditions) ./ d_p3.dr(fit_conditions);
            ep = d_p3.ep(fit_conditions) ./ d_p3.dp(fit_conditions);

            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            Y = mp - mr;
            X = er .* mr - ep .* mp + mp - mr;
            
            params = (X' \ Y') * 2;
        end

    end
end
