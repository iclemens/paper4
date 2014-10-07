function Rsq = plot_p4(data_all)

    % Compute rsq per participant
    % Keep params for 7 constant and moditfy those for only one.
    
    
    for j = 1:8
        data.mup(:, j) = data_all.output_p4(j).data.mup;
        data.muppred(:, j) = data_all.output_p4(j).pred.mup;
    end
    
    colors = color_scheme(1);
    symbols = '<>v^osph';

    
    % %%%%%% %
    %        %
    % %%%%%% %
    
    % Perform tests based on these trials:
    ss_tst = 1:8;
    
    % Collapse conditions
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

    
    % %%%%%% %
    % Figure %
    % %%%%%% %
    
    cla;
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
    
    fprintf(' Parameters = [ ...\n');
    for i = 1:8
        fprintf(' %.2f; ...\n', data_all.output_p3(i).fit);
    end
    fprintf(']\n');

end


function y = lin(x)
    y = x(:);
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
