
sigma_hat = nan(12, 8);
clear b;

fprintf('-----------\n');
for i = 1:8
  order = [0; 1; 0; 1; 0; 1; 0; 1; 0; 1; 0; 1];

  Y = sigma(:, i);  
  X = [order, mu(:, i), ones(12, 1)];
  
  [b(:, i), ~, ~, ~, stat] = regress(Y, X);
  
  sigma_hat(:, i) = X*b(:, i);
  
  fprintf('R2: %.2f\n', stat(1));
  
  subplot(2, 4, i);
  
  c = 'rrrrggggbbbb'; cla; hold on;
  for j = 1:12  
    plot(sigma(j, i), sigma_hat(j, i), 'x', 'Color', c(j), 'LineWidth', 2);
  end
  
  line(xlim, xlim);
  
  title(sprintf('R2: %.2f', stat(1)));
  xlabel('Sigma hat');
  ylabel('Sigma');
end


% Interaction term only useful in participants 4 and 7
% mu(:, i) .* order,

% Mu is crucial for participant 7



