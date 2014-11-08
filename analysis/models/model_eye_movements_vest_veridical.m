classdef model_eye_movements_vest_veridical

    methods(Static = true)
        function name = get_name()
            name = 'Eye movements Vest Veridical';
        end
        
        function labels = get_param_names()
          labels = {
            'Alpha'
            };
        end        
        
        function predictions = predict_mu_second(params, data)            
            a = params * data.e1 ./ data.d1 + 1;
            b = params * data.e2 ./ data.d2 + 1;
            
            predictions = (data.m1 .* a) ./ b;            
        end
        
        function predictions = predict_mu_probe(params, data)           
            a = params * data.er ./ data.dr + 1;
            b = params * data.ep ./ data.dp + 1;
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(d_p3, ~)
            if any(numel(d_p3.er) == [6 10])
                fit_conditions = 1:2;
            elseif any(numel(d_p3.er) == [12 20])
                fit_conditions = 1:4;
            end

            
            %alpha * er/dr*mr + mr = alpha * ep/dp*mp + mp
            
            %alpha * (er/dr*mr - ep/dp*mp) = mp - mr
            
            er = d_p3.er(fit_conditions) ./ d_p3.dr(fit_conditions);
            ep = d_p3.ep(fit_conditions) ./ d_p3.dp(fit_conditions);
        
            mr = d_p3.mr(fit_conditions);
            mp = d_p3.mp(fit_conditions);
            
            Y = mp - mr;
            X = er .* mr - ep .* mp;
            
            params = X' \ Y';
        end

    end

end