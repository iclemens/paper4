classdef model_combined_d50fixed
    
    methods(Static = true)
        function name = get_name()
            name = 'Combined D50';
        end
        
        function labels = get_param_names()
          labels = {
            'A50', 'A200', 'D200'
            };
        end        
        
        function predictions = predict_mu_probe(params, data)
            params = [params(1) params(2) 0.5 params(3)];
          
            pr = ifc(data.dr == 0.5, params(1), params(2));
            pp = ifc(data.dp == 0.5, params(1), params(2));

            dr = ifc(data.dr == 0.5, params(3), params(4));
            dp = ifc(data.dp == 0.5, params(3), params(4));
            
            a = dr .* pr .* data.er ./ data.dr + (1 - pr);
            b = dp .* pp .* data.ep ./ data.dp + (1 - pp);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(data)
            % Parameters:a
            % Alpha50, Alpha200, D50, D200
            
           options = optimset('Display', 'None', 'algorithm', 'active-set');
                        
            lb = [0 0 0.5 1e-5];
            ub = [1 1 0.5 1e5];                                    
            
            N = 200;
            
            p0(:, 1) = min(max(0, normrnd(0.5, 0.4, N, 1)), 1);
            p0(:, 2) = min(max(0, normrnd(0.5, 0.4, N, 1)), 1);
            p0(:, 3) = 0.5;
            p0(:, 4) = min(max(1e-5, normrnd(2.0, 4, N, 1)), 1e5);
            
            params = nan(N, 4);
            
            h = waitbar(0, 'Please wait...');
            
            for i = 1:N
              
              try
                [params(i, :) fval(i), exitflag(i)] = fmincon(@(params) sum((model_combined.predict_mu_probe(params, data) - data.mp) .^ 2), ...
                      p0(i, :), ...
                      [], [], [], [], lb, ub, [], options);
                waitbar(i/N, h);                    
              catch
              end
            end
            
            try
              close(h);
            catch
            end
            
            fval(exitflag < 1) = NaN;            
            [~, I] = min(fval);            
            params = params(I, :);
            
            params = params([1 2 4]);
        end
    end
end
