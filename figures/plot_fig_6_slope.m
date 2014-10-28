function plot_fig_6_slope
    global global_config;
    
    data = load('../analysis/psychometrics_p3.mat');
    
    % Load data
    colors = color_scheme(1);
    symbols = '<>v^osph';
    
    
    
    %mu = data.collapsed.mu;
    %sigma = data.collapsed.sigma;
    
    mu = data.mu;
    sigma = data.sigma;
    
    X = linspace(0, 0.25, 20);
    
    % A few models
    b_lin = regress(sigma(:), [mu(:) ones(numel(mu), 1)]);
    s_lin = b_lin(1) * mu + b_lin(2);
    x_lin = b_lin(1) * X + b_lin(2);
    
    for i = 1:8
        b_l(:, i) = regress(sigma(:, i), [mu(:, i) ones(size(mu, 1), 1)]);
        s_l(:, i) = b_l(1, i) * mu(:, i) + b_l(2, i);
    end
    
    b_log = regress(log(sigma(:)), [(mu(:)) ones(numel(mu), 1)]);
    s_log = exp(b_log(1) * mu + b_log(2));
    x_log = exp(b_log(1) * X + b_log(2));
    
    b_sqr = regress(sigma(:), [mu(:) .^ 2 mu(:) ones(numel(mu), 1)]);
    s_sqr = b_sqr(1) * mu .^ 2 + b_sqr(2) * mu + b_sqr(3);
    x_sqr = b_sqr(1) * X .^ 2 + b_sqr(2) * X + b_sqr(3);
    

    % Create plot
    figure(6); clf; hold on;    
    handle_axes = subplot(1, 1, 1);
    
    xlim([0 0.25] - 0.125);
    ylim([0 0.15]);
    
    h = plot(X - 0.1, x_lin);
    
    set(h, 'Color', 'k', 'LineStyle', '--');
    
    for s = 1:8
      for c = 1:6
          color = colors(c, :);
        
          h = plot(mu(c, s) - 0.1, sigma(c, s), symbols(s), 'Color', colors(c, :));
          
          set(h, ...
                    'MarkerFaceColor', 0.4 * [1 1 1] + 0.6 * color, ...
                    'MarkerEdgeColor', color, ...
                    'MarkerSize', 3);          
      end
    end

    xlabel(handle_axes, '\Delta distance (cm)', 'FontSize', 12);
    ylabel(handle_axes, 'Sigma (cm)', 'FontSize', 12);
    
    % Styling
    set(handle_axes, ...
      'FontSize', 10, ...
      'XTick', [-0.1 0 0.1 0.2], ...
      'YTick', [0 0.1], ...
      'XTickLabel', {'-10', '0', '10', '20'}, ...
      'YTickLabel', {'0', '10'});   
  
    axis square;
  
    orient(gcf, 'Portrait');
    set(gcf, ...
        'Units', 'centimeters', ...
        'PaperUnits', 'centimeters', ...
        'Position', [0 0 8.5 5], ...
        'PaperPosition', [0 0 8.5 5]);

    text(0.03, 0.13, sprintf('R^2 = %.2f', r_squared(sigma(:), s_l(:))), 'FontSize', 8);
    
    fprintf('R squared (one slope): %.2f\n', r_squared(sigma(:), s_lin(:)));
    fprintf('R squared (mlt slope): %.2f\n', r_squared(sigma(:), s_l(:)));

    outputFile = sprintf('%s/paper3_figure6.eps', global_config.figure_directory_p3);
    export_fig('-transparent', '-nocrop', '-eps', outputFile);    
end