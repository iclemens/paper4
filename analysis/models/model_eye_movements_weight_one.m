classdef model_eye_movements_weight_one

    methods(Static = true)
        function name = get_name()
            name = 'Eye movements not weighted';
        end
        
        function labels = get_param_names()
          labels = {
            'Beta'
            };
        end        
        
        function predictions = predict_mu_second(params, data)            
            weye = 1;
            
            a = weye * data.e1 ./ data.d1 + params;
            b = weye * data.e2 ./ data.d2 + params;
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        function predictions = predict_mu_probe(params, data) 
            weye = 1;
            a = weye * data.er ./ data.dr + params;
            b = weye * data.ep ./ data.dp + params;
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(d_p3, ~)
            if any(numel(d_p3.er) == [6 10])
                fit_conditions = 1:2;
            elseif any(numel(d_p3.er) == [12 20])
                fit_conditions = 1:4;
            end

            
            % er/dr*mr + beta * mr = ep/dp*mp + beta * mp            
            % ep/dp*mp - er/dr*mr = beta * (mr - mp)
            
            er = d_p3.er(fit_conditions) ./ d_p3.dr(fit_conditions);
            ep = d_p3.ep(fit_conditions) ./ d_p3.dp(fit_conditions);
        
            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            Y = (er .* mr - ep .* mp);
            X = mp - mr;            
                        
            params = X' \ Y';
        end

    end

end