classdef model_paper3_alpha_beta

    methods(Static = true)
        function name = get_name()
            name = 'Paper3_Alpha_Beta';
        end
        
        function labels = get_param_names()
          labels = {
            'Alpha', 'Beta'
            };
        end        
        
        function predictions = predict_mu_second(params, data)            
            a = params(1) * data.e1 ./ data.d1 + params(2);
            b = params(1) * data.e2 ./ data.d2 + params(2);
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        function predictions = predict_mu_probe(params, data)           
            a = params(1) * data.er ./ data.dr + params(2);
            b = params(1) * data.ep ./ data.dp + params(2);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(d_p3, ~)
            if any(numel(d_p3.er) == [6 10])
                fit_conditions = 1:2;
            elseif any(numel(d_p3.er) == [12 20])
                fit_conditions = 1:4;
            end

            er = d_p3.er(fit_conditions);
            dr = d_p3.dr(fit_conditions);
            ep = d_p3.ep(fit_conditions);
            dp = d_p3.dp(fit_conditions);

            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            
            tmp = struct('er', er, 'ep', ep, ...
                         'dr', dr, 'dp', dp, ...
                         'mr', mr, 'mp', mp);

            params = fminsearch( ...
              @(params) sum((model_paper3_alpha_beta.predict_mu_probe(params, tmp) - tmp.mp) .^ 2), [0.5 0.5]);                        
        end

    end
end
