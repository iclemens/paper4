function plot_fig_5_p3_pse_prediction()
    global global_config;
    
    lin = @(x) x(:);
    
    data_all = load('../analysis/model_hfd_3999');
    
    for j = 1:8
        data.mup(:, j) = data_all.output_p3(j).data.mup;
        data.muppred(:, j) = data_all.output_p3(j).pred.mup;
    end
    
    colors = color_scheme(1);
    symbols = '<>v^osph';
    main();
    
        
    function main()
        % Fit model based on these trials:
        ss_fit = 1:4;
        
        % Perform tests based on these trials:
        ss_tst = 5:12;
        
        % Collapse conditions
        ss_fit = ss_fit(2:2:end) / 2;
        ss_tst = ss_tst(2:2:end) / 2;
        
        fields = fieldnames(data);
        for i_field = 1:numel(fields)
            field = fields{i_field};
            
            if field(end) == '1' || field(end) == '2'
                data = rmfield(data, field);
            else
                data.(field) = 0.5 * (data.(field)(1:2:end, :) + data.(field)(2:2:end, :));
            end
        end
        
        % Prepare figure
        figure(10);
        clf;
        hold on;
        
        handle_identity_line = line([0.05 0.2], [0.05 0.2]);
        handle_noeye_line = line([0.05 0.2], [0.1 0.1]);
        
        for i_tst_condition = 1:numel(ss_tst)
            i_condition = ss_tst(i_tst_condition);
            color = colors(i_condition, :);
            
            for i_participant = 1:8
                X = data.mup(i_condition, i_participant);
                Y = data.muppred(i_condition, i_participant);
                
                handle_datapoint = plot(lin(X), lin(Y), symbols(i_participant));
                
                set(handle_datapoint, ...
                    'MarkerFaceColor', 0.4 * [1 1 1] + 0.6 * color, ...
                    'MarkerEdgeColor', color, ...
                    'MarkerSize', 3);
            end
        end
        
        %L = sum(log(1e-10 + (1-2e10) * abs(data.muppred(ss_tst, :) - data.mup(ss_tst, :))));
        %size(L)
        L = NaN;
        
        for i_tst_condition = 1:numel(ss_tst)
            i_condition = ss_tst(i_tst_condition);
            color = colors(i_condition, :);
            
            X = data.mup(i_condition, :);
            Y = data.muppred(i_condition, :);
            
            wd = 0.003;
            
            handle_errorbars = [ ...
                line(mean(X) + [-1 1] * std(X), mean(Y) * [1 1]);
                line(mean(X) * [1 1], mean(Y) + [-1 1] * std(Y));
                
                line(mean(X) + [-wd wd], mean(Y) - [1 1] * std(Y));
                line(mean(X) + [-wd wd], mean(Y) + [1 1] * std(Y));
                
                line(mean(X) - [1 1] * std(X), mean(Y) + [-wd wd]);
                line(mean(X) + [1 1] * std(X), mean(Y) + [-wd wd]);
                ];
            
            set(handle_errorbars, 'Color', color, 'LineWidth', 1);
        end
        
        xlabel('Actual PSE (cm)', 'FontSize', 12);
        ylabel('Predicted PSE (cm)', 'FontSize', 12);
        
        % Style
        axis equal;
        xlim([0.05 0.17]);
        ylim([0.05 0.17]);
        
        set(gca, ...
            'FontSize', 10, ...
            'XTick', [0.05 0.1 0.15 0.2], ...
            'XTickLabel', {'5', '10', '15', '20'}, ...
            'YTick', [0.05 0.1 0.15 0.2], ...
            'YTickLabel', {'5', '10', '15', '20'});
        
        set(gcf, ...
            'PaperUnits', 'Centimeters', ...
            'PaperOrientation', 'Portrait', ...
            'Units', 'Centimeters', ...
            'PaperPosition', [0 0 8.5 5], ...
            'Position', [0 0 8.5 5]);
        
        set(handle_identity_line, 'Color', 'k', 'LineStyle', '--');
        set(handle_noeye_line, 'Color', 'k', 'LineStyle', '--');
        
        Rsq = r_squared(data.mup(ss_tst, :), data.muppred(ss_tst, :));
        fprintf('R squared: %.2f\n', Rsq);
        
        % Print performance figures
        for flag = [1 0]
            [s1, rho, p] = performance(data.mup(ss_tst, :), data.muppred(ss_tst, :), flag);
            
            fprintf('Model performance:\n');
            fprintf('------------------\n');
            fprintf('Likelihood: %.2f\n', sum(L));
            fprintf('Rho = %.2f, p = %.2f\n', rho, p);
            fprintf('Slope = %.2f\n', s1);
            fprintf('AIC: %.2f\n', 2 * 3 - 2 * sum(L));
            fprintf('\n');
        end
        
        fprintf(' Parameters = [ ...\n');
        for i = 1:8
            fprintf(' %.2f; ...\n', data_all.output_p3(i).fit);
        end
        fprintf(']\n');
        
        %export_fig('-transparent', '-nocrop', '-eps', sprintf('%s/paper3_figure5.eps', global_config.figure_directory_p3));
    end

    
    function [slope, rho, p] = performance(x, y, flag)
        if nargin < 3, flag = 0; end;
        
        if flag
            slope = regress(y(:) - x(:), x(:));
            [rho, p] = corr(x(:), y(:) - x(:));
        else
            slope = regress(y(:), x(:));
            [rho, p] = corr(x(:), y(:));
        end
    end    
end
