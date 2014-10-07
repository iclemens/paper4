function [x, y] = smooth_response(tmp)
  
  x = 0:0.01:0.3;
  y = zeros(size(x));
  q = zeros(size(x));
  
  yn = zeros(size(x));
  yp = zeros(size(x));
  
  for i = 1:length(x)
    weights = normpdf(tmp(:, 1), x(i), 0.01);
    q(i) = sum(weights);
    weights = weights / q(i);
    
    yn(i) = 0.5 - 0.5 * -sum(weights .* (tmp(:, 2) - 1));
    yp(i) = 0.5 * sum(weights .* tmp(:, 2));
    
    y(i) = yn(i) + yp(i);
  end
  
  th = 20;
  y(q < th) = NaN;
  
end