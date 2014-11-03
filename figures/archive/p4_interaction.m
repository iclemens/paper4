%% Load data

data3 = load('../analysis/psychometrics_p3.mat');
data4 = load('../analysis/psychometrics_p4.mat');


%% Combine mu values

mu3 = 0.5 * (data3.mu(1:2:end, :) + data3.mu(2:2:end, :));
mu4 = 0.5 * (data4.mu(1:2:end, :) + data4.mu(2:2:end, :));

labels3 = {'BW', 'WB', 'FW', 'WF', 'BF', 'FB'};
labels4 = {'B(NF)', 'B(FN)', 'W(NF)', 'W(FN)'};


%% Perform statistics

[p, tbl, sts] = anova2([mu([1 3], :), mu([2 4], :)]', 8, 'off');

fprintf('ANOVA results:\n');
fprintf('Near-far: %.2f    (F = %.2f, df = %d)\n', p(1), tbl{2,5}, tbl{2, 3});
fprintf('Body-world: %.2f  (F = %.2f, df = %d)\n', p(2), tbl{3,5}, tbl{3, 3});
fprintf('Interaction: %.2f (F = %.2f, df = %d)\n', p(2), tbl{4,5}, tbl{4, 3});


%% Plot

m = mean(mu, 2);
s = std(mu, [], 2);

clf; hold on;
set(gca, 'XTick', [1 2]);
set(gca, 'XTickLabel', {'Body', 'World'});

set(gca, 'YTick', [0 0.05 0.1 0.15 2]);
set(gca, 'YTickLabel', {'0', '5', '10', '15', '20'});

line([0 3], [0.1 0.1], 'Color', [1 1 1] * 0.6, 'LineStyle', '--');
plot([1 2], m([1 3]), 'b');
plot([1 2], m([2 4]), 'r');

map = [1 1 2 2];
col = ['b', 'r', 'b', 'r'];
for i = 1:4
    plot(map(i), m(i), 'o', 'MarkerFaceColor', col(i), 'MarkerEdgeColor', col(i));
    plot([map(i), map(i)], [m(i) + s(i), m(i) - s(i)], col(i));
    plot(map(i) + [-0.03 0.03], [1 1] * m(i) + s(i), col(i));
    plot(map(i) + [-0.03 0.03], [1 1] * m(i) - s(i), col(i));    
end

legend('N-F', 'F-N');

xlim([0.5 2.5]);
ylim([0 0.2]);

title('Fixation type versus fixation depth interaction effect');
