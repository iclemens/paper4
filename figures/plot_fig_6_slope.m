function plot_fig_6_slope
    global global_config;
    
    data = load('../analysis/psychometrics_p3.mat');
    
    % Load data
    colors = color_scheme(1);
    mu = data.collapsed.mu;
    sigma = data.collapsed.sigma;
    [b, ~, ~ ,~, stat] = regress(sigma(:), [mu(:) ones(numel(mu), 1)]);    

    [blog, ~, ~ ,~, stat] = regress(log(sigma(:)), [(mu(:)) ones(numel(mu), 1)]);    
    
    % Create plot
    figure(6); clf; hold on;
    
    xlim([0 0.25]);
    ylim([0 0.15]);
    
    predict = @(X) 2.71 .^ (X * blog(1) + blog(2));
    
    X = linspace(0, 0.25, 20);   
    
    plot(X, predict(X), 'k', 'LineWidth', 2);
    plot(xlim, b(2) + b(1) * xlim, 'k', 'LineWidth', 2);
    
    mu_hat = predict(mu(:));        
    
    %plot(xlim, b(2) + b(1) * xlim, 'k', 'LineWidth', 2);    
    
    for c = 1:6
        plot(mu(c, :), sigma(c, :), 'x', 'LineWidth', 2, 'Color', colors(c, :));
    end
        
    orient(gcf, 'Portrait');
    set(gcf, ...
        'Units', 'centimeters', ...
        'PaperUnits', 'centimeters', ...
        'Position', [0 0 8.5 8.5], ...
        'PaperPosition', [0 0 8.5 8.5]);
    
    figure(7); plot(mu, log(sigma), 'x', 'LineWidth', 2);
    stat(1)
end