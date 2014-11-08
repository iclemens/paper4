classdef model_eye_movements_not_weighted

    methods(Static = true)
        function name = get_name()
            name = 'Eye movements not weighted';
        end
        
        function labels = get_param_names()
          labels = {
            'Alpha'
            };
        end        
        
        function predictions = predict_mu_second(params, data)            
            weye = 0;
            
            a = weye * data.e1 ./ data.d1 + params;
            b = weye * data.e2 ./ data.d2 + params;
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        function predictions = predict_mu_probe(params, data) 
            weye = 0;
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

            
            %alpha * er/dr*mr + mr = alpha * ep/dp*mp + mp
            
            % \beta mr = \beta mp            
            
            er = d_p3.er(fit_conditions) ./ d_p3.dr(fit_conditions);
            ep = d_p3.ep(fit_conditions) ./ d_p3.dp(fit_conditions);
        
            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            Y = mp - mr;
            X = er .* mr - ep .* mp;
            
            Y = (mp - mr) .* 0;
            X = mr - mp;            
            
            params = X' \ Y';
        end

    end

end