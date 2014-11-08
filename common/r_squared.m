%
% R_SQUARED(y, f)
%
% Compute R squared
%  y - Actual value
%  f - Predicted value
%
function Rsq = r_squared(y, f)
    my = mean(y(:));
    
    SStot = sum((y(:) - my) .^ 2);    % Total sum of squares
    SSreg = sum((f(:) - my) .^ 2);    % Regression sum of squares
    SSres = sum((y(:) - f(:)) .^ 2);  % Sum of squares of residuals
    
    Rsq = 1 - (SSres ./ SStot);
end