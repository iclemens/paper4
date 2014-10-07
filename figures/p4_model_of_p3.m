function p4_model_of_p3()
    lin = @(x) x(:);
    
    models = {'emv', 'hfd'};
    n_models = numel(models);
    
    % Load data
    for i = 1:n_models
        data = load(sprintf('../analysis/model_%s_3999', models{i}));
    
        for j = 1:8
            data{i}.mup(:, j) = data.output_p4(j).data.mup;
            data{i}.muppred(:, j) = data.output_p4(j).pred.mup;
        end
        
        data{i} = reduce_conditions(data{i});
    end
    
    colors = color_scheme(1);
    %symbols = '<>v^osph';
    symbols = 'oooooooo';
    
    data = reduce_conditions(data);
    
    % Prepare figure
    figure(6);
    
    if strcmp(model, 'emv')
        subplot(1, 2, 1);
    else
        subplot(1, 2, 2);
    end
    
    clf;
    hold on;
    
    title(model);
    
    handle_identity_line = line([0.05 0.2], [0.05 0.2]);
    handle_noeye_line = line([0.05 0.2], [0.1 0.1]);
    
    % ...
    for i_condition = 1:4
        color = colors(i_condition, :);
        
        for i_participant = 1:8
            X = data.mup(i_condition, i_participant);
            Y = data.muppred(i_condition, i_participant);
            
            handle_datapoint = plot(lin(X), lin(Y), symbols(i_participant));
            
            set(handle_datapoint, ...
                'MarkerFaceColor', 0.4 * [1 1 1] + 0.6 * color, ...
                'MarkerEdgeColor', color, ...
                'MarkerSize', 4);
            
            %handles = errorcross(X, Yb, 0.0001);
            %set(handles, 'Color', color);
            %handle_errorbars = errorcross(X, Y, 0.003);
            %set(handle_errorbars, 'Color', color, 'LineWidth', 1);
        end
    end
    
    
    for i_condition = 1:4
        color = colors(i_condition, :);
        
        X = data.mup(i_condition, :);
        Y = data.muppred(i_condition, :);
        
        handle_errorbars = errorcross(X, Y, 0.003);
        set(handle_errorbars, 'Color', color, 'LineWidth', 1);
    end
    
    X = data.mup(:);
    Y = data.muppred(:);
    
    [slope, rho, p] = performance(X, Y, 2);
    
    h = line([0.05, 0.2], slope(2) + slope(1) * [0.05 0.2]);
    set(h, 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--');
    
    %line([-0.05, 0.1]+0.1, (0.1 + [-0.05 0.1]) * slope);
    %line([-0.05, 0.1]+0.1, 0.1 + [-0.05 0.1] * slope);
    
    fprintf('Slope = %.2f; rho = %.2f; p = %.2f\n', slope(1), rho, p);
    
    xlabel('Actual PSE (cm)', 'FontSize', 12);
    ylabel('Predicted PSE (cm)', 'FontSize', 12);
    
    set(handle_identity_line, 'Color', 'k', 'LineStyle', '--');
    set(handle_noeye_line, 'Color', 'k', 'LineStyle', '--');
end


%
% Combines related conditions by averaging them.
%
function data = reduce_conditions(data)
    fields = fieldnames(data);
    for i_field = 1:numel(fields)
        field = fields{i_field};
        
        if field(end) == '1' || field(end) == '2'
            data = rmfield(data, field);
        else
            data.(field) = 0.5 * (data.(field)(1:2:end, :) + data.(field)(2:2:end, :));
        end
    end
end


%
% Compute performance statistics.
%
function [slope, rho, p] = performance(x, y, flag)
    if nargin < 3, flag = 0; end;
    
    if flag == 1
        slope = regress(y(:) - x(:), x(:));
        [rho, p] = corr(x(:), y(:) - x(:));
    elseif flag == 0
        slope = regress(y(:), x(:));
        [rho, p] = corr(x(:), y(:));
    elseif flag == 2
        slope = regress(y(:), [x(:) ones(size(x(:)))]);
        [rho, p] = corr(x(:), y(:));
    end
end


%
% Plot both horizontal and vertical errorbars.
%
function handles = errorcross(X, Y, wd)
    handles = [ ...
        line(nanmean(X) + [-1 1] * nanstd(X), nanmean(Y) * [1 1]);
        line(nanmean(X) * [1 1], nanmean(Y) + [-1 1] * nanstd(Y));
        
        line(nanmean(X) + [-wd wd], nanmean(Y) - [1 1] * nanstd(Y));
        line(nanmean(X) + [-wd wd], nanmean(Y) + [1 1] * nanstd(Y));
        
        line(nanmean(X) - [1 1] * nanstd(X), nanmean(Y) + [-wd wd]);
        line(nanmean(X) + [1 1] * nanstd(X), nanmean(Y) + [-wd wd]);
        ];
end

