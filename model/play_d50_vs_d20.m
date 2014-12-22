
data = load(fullfile(global_config.models_directory, 'MDL_Two alphas V1-a.mat'));
R = data.params(:, 1) ./ data.params(:, 2);

data4 = load(fullfile(global_config.models_directory, 'MDL_Two alphas V1-a Fit P4 only.mat'));
R4 = data4.params(:, 1) ./ data4.params(:, 2);

clf; hold on;
line([0.5 8.5], [1 1], 'LineStyle', '--', 'Color', 'black');
line([0.5 8.5], [4 4], 'LineStyle', '--', 'Color', 'black');
plot(1:8, R, 'x', 'LineWidth', 2);
plot(1:8, R4, 'rx', 'LineWidth', 2);

xlim([0.5 8.5]);
ylim([0 4.5]);

xlabel('Participant');
ylabel('d200 / d50');

%%

clf; hold on;
plot(data.params(:, 1), data4.params(:, 1), 'bx', 'LineWidth', 2);
plot(data.params(:, 2), data4.params(:, 2), 'rx', 'LineWidth', 2);

line(xlim, xlim, 'LineStyle', '--', 'Color', 'k');
lsline;
axis equal;
