classdef model_3a_two_alphas_vv < base_model

    methods(Access = public)
        
        function obj = model_3a_two_alphas_vv()
            obj.conditions = 1:10;
            obj.name = 'Two alphas VV';
            obj.param_names = {'A50', 'A200'};
        end


        function predictions = predict_mu_probe(~, params, d) 
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
                
                X(sr, i) = X(sr, i) + phi_r(i);
                X(sp, i) = X(sp, i) - phi_p(i);
            end
                        
            Yhat = X' * params(:);
            predictions = Yhat' + d.mr;
        end
        
        
        function params = solve_params(obj, data)
            d = filter_conditions(data, obj.conditions);

            % Compute eye movement angle
            phi_r = (d.er .* d.mr) ./ d.dr;
            phi_p = (d.ep .* d.mr) ./ d.dp;

            % Build Y = aX matrices
            Y = d.mp - d.mr;            
            X = zeros(2, numel(Y));
            
            for i = 1:numel(d.dr)                
                sr = (d.dr(i) == 2.0) + 1;
                sp = (d.dp(i) == 2.0) + 1;
                
                X(sr, i) = X(sr, i) + phi_r(i);
                X(sp, i) = X(sp, i) - phi_p(i);
            end
            
            % Solve set of equations
            params = (X' \ Y') * 2;
        end
    end
end
