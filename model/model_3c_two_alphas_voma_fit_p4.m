classdef model_3c_two_alphas_voma_fit_p4

    methods(Static = true)       
        
        function name = get_name()
            name = 'Two alphas V1-a Fit P4 only';
        end
        
        function labels = get_param_names()
          labels = {
            'A50', 'A200'
            };
        end        
                
        function predictions = predict_mu_probe(params, d) 
            params = params / 2;
  
            % Compute eye movement angle
            phi_r = (d.er .* d.mr) ./ d.dr;
            phi_p = (d.ep .* d.mr) ./ d.dp;

            % Build Y = aX matrices
            Y = d.mp - d.mr;            
            X = zeros(2, numel(Y));
            
            for i = 1:numel(d.dr)                
                sr = (d.dr(i) == 2.0) + 1;
                sp = (d.dp(i) == 2.0) + 1;
                
                X(sr, i) = X(sr, i) + (phi_r(i) - d.mr(i));
                X(sp, i) = X(sp, i) - (phi_p(i) - d.mp(i));
            end
                        
            Yhat = X' * params(:);
            predictions = Yhat' + d.mr;
        end
        
        function params = solve_params(data, ~)
            d = filter_conditions(data, 7:numel(data.er));

            % Compute eye movement angle
            phi_r = (d.er .* d.mr) ./ d.dr;
            phi_p = (d.ep .* d.mr) ./ d.dp;

            % Build Y = aX matrices
            Y = d.mp - d.mr;            
            X = zeros(2, numel(Y));
            
            for i = 1:numel(d.dr)                
                sr = (d.dr(i) == 2.0) + 1;
                sp = (d.dp(i) == 2.0) + 1;
                
                X(sr, i) = X(sr, i) + (phi_r(i) - d.mr(i));
                X(sp, i) = X(sp, i) - (phi_p(i) - d.mp(i));
            end
            
            % Solve set of equations
            params = (X' \ Y') * 2;
        end

    end
end
