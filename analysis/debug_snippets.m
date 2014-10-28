
%% Plot actual vs predicted for PP3

p = 3;

clf; hold on;

mpp = tmp.output_p3(p).pred.mp;
mpa = tmp.output_p3(p).data.mp;

plot(mpa(1:2), mpp(1:2), 'kx', 'LineWidth', 4, 'MarkerSize', 10);

plot(mpa(3:end), mpp(3:end), 'bx', 'LineWidth', 4, 'MarkerSize', 10);

mpp = tmp.output_p4(p).pred.mp;
mpa = tmp.output_p4(p).data.mp;

plot(mpa, mpp, 'rx', 'LineWidth', 4, 'MarkerSize', 10);

xlabel('Actual');
ylabel('Predicted');

r_squared(mpa, mpp)

line(xlim, xlim);


%% Investigate curves for PP3

data_p3 = load('psychometrics_p3.mat');
data_p4 = load('psychometrics_p4.mat');

%%

clf; hold on;

colors = 'kmgybbbbbbbb';

line([0.1 0.1], [0 1], 'Color', 'k');
line([0 0.4], [0.5 0.5], 'Color', 'k');

for i = 1:4
  curve = data_p3.fit{i, 7};
  
  mu = curve.params.est(1);
  sigma = curve.params.est(2);
  gamma = curve.params.est(3);
  
  mu_std = std(curve.params.sim(:, 1));
  sigma_std = std(curve.params.sim(:, 2));
  
  X = linspace(0, 0.4, 100);
  Y = gamma + (1 - 2 * gamma) * normcdf(X, mu, sigma);
  plot(X, Y, 'Color', colors(i), 'LineWidth', 2);
  
  Y = gamma + (1 - 2 * gamma) * normcdf(X, mu - mu_std, sigma);
  plot(X, Y, 'Color', colors(i), 'LineWidth', 2);
  
  Y = gamma + (1 - 2 * gamma) * normcdf(X, mu + mu_std, sigma);
  plot(X, Y, 'Color', colors(i), 'LineWidth', 2);
  
end

shg


%% Order effect

mu = data_p3.mu(1:4, :);
gain_first = data_p3.eye_gain_extended.gain(:, 1:2, 1)';
gain_second = data_p3.eye_gain_extended.gain(:, 1:2, 2)';

% Bw wB Wb bW
M = [0.1 mu(1, 3); mu(2, 3) 0.1; 0.1 mu(3, 3); mu(4, 3) 0.1];
E = [gain_first(1, 3) gain_second(1, 3); gain_first(2, 3) gain_second(2, 3); gain_first(2, 3) gain_second(2, 3); gain_first(1, 3) gain_second(1, 3)];


prediction = alpha * E .* M + (1 - alpha) * M;



clf; hold on;
plot(prediction(:, 1), M(:, 2), 'x');


%% Sigma

lin = @(x) x(:);


mu = data_p3.mu(:, :);
sigma = data_p3.sigma(:, :);

clf; hold on;

titles = {'Body & World', 'World & Free', 'Body & Free'};

for i = 1:3
  r = (i-1)*4 + (4);
  M = log(mu(r, :));
  S = log(sigma(r, :));
  
  subplot(1, 3, i);
  plot(M(:), S(:), 'kx', 'LineWidth', 2);
  
  [b,~,~,~,stats] = regress(S(:), [M(:) ones(numel(M),1)]);
  axis square; title(sprintf('%s (%.2f)', titles{i}, stats(1)));
end

xlabel('Mu');
ylabel('Sigma');
shg

%% Sigma avg per condition

combine_sigma = @(a, b) 0.5 * (a + b);
combine_sigma = @(a, b) 0.5 * (a.^2 + b.^2);

mu_c = 0.5 * (mu(1:2:end, :) + mu(2:2:end, :));
sigma_c = combine_sigma(sigma(1:2:end, :), sigma(2:2:end, :));

clf; plot(mu_c, sigma_c, 'kx', 'LineWidth', 2);
lsline

%%

combine_sigma = @(a, b) sqrt(1./(1./a.^2 +1./b.^2));

mu_c = 0.5 * (mu(1:2:end, :) + mu(2:2:end, :));
sigma_c = combine_sigma(sigma(1:2:end, :), sigma(2:2:end, :));

clf;

for i = 1:8
  subplot(2, 4, i); cla; hold on;
  %plot(mu(:, i), sigma(:, i), 'bx', 'LineWidth', 2);
  plot(mu_c(:, i), sigma_c(:, i), 'kx', 'LineWidth', 2);
  lsline
  
  [~, ~, ~, ~, stat] = regress(sigma_c(:, i), [mu_c(:, i), ones(6, 1)]);
  title(sprintf('%.2f', stat(1)));
end
shg;

%%
for i = [0 1 2]
  subplot(1, 3, i + 1); hold on;
  plot(mu_c(i * 2 + 1, :), sigma_c(i * 2 + 1, :), 'rx', 'LineWidth', 2);
  plot(mu_c(i * 2 + 2, :), sigma_c(i * 2 + 2, :), 'bx', 'LineWidth', 2);
end


%%

mu = data_p3.collapsed.mu;

mu_low = cellfun(@(x) x.params.lims(2, 1), data_p3.collapsed.fit);
mu_high = cellfun(@(x) x.params.lims(3, 1), data_p3.collapsed.fit);

sigma = data_p3.collapsed.sigma;
sigma_low = cellfun(@(x) x.params.lims(2, 2), data_p3.collapsed.fit);
sigma_high = cellfun(@(x) x.params.lims(3, 2), data_p3.collapsed.fit);

col = 'kkrrgg';

for i = 1:8
  subplot(2, 5, i); cla; hold on;
  for c = 1:6
    errorcross([mu_low(c, i) mu(c, i) mu_high(c, i)], [sigma_low(c, i) sigma(c, i) sigma_high(c, i)], col(c));
  end
  
  [~, ~, ~, ~, stat] = regress(sigma(:, i), [mu(:, i), ones(6, 1)]);
  title(sprintf('%.2f', stat(1)));
end

subplot(2,5,10);
plot(mu(:), sigma(:), 'x', 'LineWidth', 2);
[~, ~, ~, ~, stat] = regress(sigma(:), [mu(:) ones(numel(mu))]);
title(sprintf('%.2f', stat(1)));

%%

clf;

plot(mu(:), sigma(:), 'x', 'LineWidth', 2);
[~, ~, ~, ~, stat] = regress(sigma(:), [mu(:) ones(numel(mu))]);
title(sprintf('R^2: %.2f', stat(1)));

lsline;

xlabel('Mu');
ylabel('Sigma');


%   set(gca, ...
%     'FontSize', 10, ...
%     'XTick', [0.05 0.1 0.15 0.2], ...
%     'XTickLabel', {'5', '10', '15', '20'}, ...
%     'YTick', [0.05 0.1 0.15 0.2], ...
%     'YTickLabel', {'5', '10', '15', '20'});

axis square;

set(gcf, ...
  'PaperUnits', 'Centimeters', ...
  'PaperOrientation', 'Portrait', ...
  'Units', 'Centimeters', ...
  'PaperPosition', [0 0 8.5 5], ...
  'Position', [0 0 8.5 5]);


%% Show curve quality for individual participant

clear all; close all;
data = load('psychometrics_p3');

for participant = 1:8
  fits = data.fit(:, participant);
  
  mu = cellfun(@(fit) fit.params.est(1), fits);
  sigma = cellfun(@(fit) fit.params.est(2), fits);
  
  figure(participant); clf;
  for i = 1:12
    subplot(3, 4, i); hold on;
    plot(fits{i}.params.sim(:, 1), fits{i}.params.sim(:, 2), '.');
    
    xlim([0 0.3]);
    ylim([0 0.4]);
    
    line(xlim, sigma(i) * [1 1], 'Color', 'r');
    line(mu(i) * [1 1], ylim, 'Color', 'r');
  end
end


%% ...


