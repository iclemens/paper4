classdef model_combined
    
    methods(Static = true)
        function name = get_name()
            name = 'Combined';
        end
        
        function predictions = predict_mu_second(params, data)
            p1 = ifc(data.d1 == 0.5, params(1), params(2));
            p2 = ifc(data.d2 == 0.5, params(1), params(2));

            d1 = ifc(data.d1 == 0.5, params(3), params(4));
            d2 = ifc(data.d2 == 0.5, params(3), params(4));
            
            a = d1 .* p1 .* data.e1 ./ data.d1 + (1 - p1);
            b = d2 .* p2 .* data.e2 ./ data.d2 + (1 - p1);
            
            predictions = (data.m1 .* a) ./ b;   
        end
        
        function predictions = predict_mu_probe(params, data)
            pr = ifc(data.dr == 0.5, params(1), params(2));
            pp = ifc(data.dp == 0.5, params(1), params(2));

            dr = ifc(data.dr == 0.5, params(3), params(4));
            dp = ifc(data.dp == 0.5, params(3), params(4));
            
            a = dr .* pr .* data.er ./ data.dr + (1 - pr);
            b = dp .* pp .* data.ep ./ data.dp + (1 - pp);
            
            predictions = (data.mr .* a) ./ b;
        end
        
        function params = solve_params(data)
            %data = reduce_data(data, [1:4 13:20]);
            
            % Parameters:
            % Alpha50, Alpha200, D50, D200
            
            options = optimset('Display', 'None', 'algorithm', 'active-set');
            
            p0 = [0.5 0.5 0.5 0.5];            
            
            lb = [0 0 1e-5 1e-5];
            ub = [1 1 1e5 1e5];            
            
            try
                params = fmincon(@(params) sum((model_combined.predict_mu_probe(params, data) - data.mp) .^ 2), p0, ...
                    [], [], [], [], lb, ub, [], options);
            catch
                params = nan(1, 4);
            end
        end
    end
end

function data = reduce_data(data, conds)
    fields = fieldnames(data);
    
    for i = 1:numel(fields)
        data.(fields{i}) = data.(fields{i})(conds);
    end
end
