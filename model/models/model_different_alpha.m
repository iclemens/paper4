classdef model_different_alpha

    methods(Static = true)
        function name = get_name()
            name = 'Depth dependend alpha';
        end
        
        function labels = get_param_names()
          labels = {
            'A50', 'A200'
            };
        end        
        
        function predictions = predict_mu_probe(params, data)
            if data.dr == 0.5
                pr = params(1);
            else
                pr = params(2);
            end
            
            if data.dp == 0.5
                pp = params(1);
            else
                pp = params(2);
            end                 
            
            a = pr * data.er + (1 - pr);
            b = pp * data.ep + (1 - pp);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(data)
            % Fit first parameter
            fit_conditions = 1:6;

            er = data.er(fit_conditions);
            ep = data.ep(fit_conditions);
        
            mr = data.mr(fit_conditions);
            mp = data.mp(fit_conditions);
            
            Y = mp - mr;
            X = er .* mr - ep .* mp + mp - mr;
            
            param_50 = X' \ Y';
            
            % Fit second parameter
            ref50 = (data.dr == 0.5);
            
            X(ref50) = data.ep(ref50) .* data.mp(ref50) - data.mp(ref50);
            Y(ref50) = param_50 * (data.er(ref50) .* data.mr(ref50) - data.mr(ref50)) + data.mr(ref50) - data.mp(ref50);

            X(~ref50) = data.ep(~ref50) .* data.mp(~ref50) - data.mp(~ref50);
            Y(~ref50) = param_50 * (data.er(~ref50) .* data.mr(~ref50) - data.mr(~ref50)) + data.mr(~ref50) - data.mp(~ref50);

            param_200 = X' \ Y';
            
            
            params = [param_50 param_200];
        end

    end

end