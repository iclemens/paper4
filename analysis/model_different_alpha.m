classdef model_different_alpha

    methods(Static = true)
        function name = get_name()
            name = 'DepthAlpha';
        end
        
        function predictions = predict_mu_second(params, data)
            if data.d1 == 0.5
                p1 = params(1);
            else
                p1 = params(2);
            end
            
            if data.d2 == 0.5
                p2 = params(1);
            else
                p2 = params(2);
            end            
            
            a = p1 * data.e1 + (1 - p1);
            b = p2 * data.e2 + (1 - p2);
            
            predictions = (data.m1 .* a) ./ b;
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
        
        function params = solve_params(d_p3, d_p4)
            % Fit first parameter
            fit_conditions = 1:4;

            er = d_p3.er(fit_conditions);
            ep = d_p3.ep(fit_conditions);
        
            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            Y = mp - mr;
            X = er .* mr - ep .* mp + mp - mr;
            
            param_50 = X' \ Y';
            
            % Fit second parameter
            ref50 = (d_p4.dr == 0.5);
            
            X(ref50) = d_p4.ep(ref50) .* d_p4.mp(ref50) - d_p4.mp(ref50);
            Y(ref50) = param_50 * (d_p4.er(ref50) .* d_p4.mr(ref50) - d_p4.mr(ref50)) + d_p4.mr(ref50) - d_p4.mp(ref50);

            X(~ref50) = d_p4.ep(~ref50) .* d_p4.mp(~ref50) - d_p4.mp(~ref50);
            Y(~ref50) = param_50 * (d_p4.er(~ref50) .* d_p4.mr(~ref50) - d_p4.mr(~ref50)) + d_p4.mr(~ref50) - d_p4.mp(~ref50);

            param_200 = X' \ Y';
            
            
            params = [param_50 param_200];
        end

    end

end