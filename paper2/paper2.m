%
% Combines models from second and third paper to see
% if curved line in figure 4 (paper 2) can be
% explained by eye angle dependent translation
% perception.
%

    rad2deg = @(rad) rad / pi * 180.0;

    alpha = 0.4;
    gamma = 0.2;

    sym = 'ssssoooossssoooo';
    
    OR = [1.2 1.2 1.2 1.2 0.8 1.0 1.4 2.0 1.2 1.2 1.2 1.2 0.8 1.0 1.4 2.0];
    OF = [0.8 1.0 1.4 2.0 1.2 1.2 1.2 1.2 0.8 1.0 1.4 2.0 1.2 1.2 1.2 1.2];
     T = -[0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15] / 2;
     
    phi = atan2(OF, T) / 1.7 * 0.15;
    
    X = rad2deg(atan2(OR, T) - atan2(OF, T));

    Tperceived = alpha * -phi + (1 - alpha) * T;
    Updated = gamma * Tperceived .* (1 ./ OR - 1 ./ OF);
    Actual = T .* (1 ./ OR - 1 ./ OF);        
    
    
    Bias = gamma .* Tperceived .* (1 ./ OR - 1 ./ OF) - T .* (1 ./ OR - 1 ./ OF);
    Bias = Bias ./ pi * 180;
    
    
    clf; hold on;
    plot(X, Bias, 'x', 'Color', [0.8 0.8 0.8]);
    lsline;
    
    for i = 1:16
        plot(X(i), Bias(i), sym(i), 'LineWidth', 2);
    end
    
    xlabel('R - F');
    shg;
    
    axis equal;
    plot(xlim, xlim, 'k--', 'LineWidth', 2);
        