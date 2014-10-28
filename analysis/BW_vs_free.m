
run_model(model_paper3_bw);
run_model(model_paper3_free);

BW = load('data/BIC_Paper3_BW.mat');
Free = load('data/BIC_Paper3_Free.mat');

%fprintf('rho = %.2f; p = %.2f; rsq = %.2f\n', rho, p, r_squared(BW.params, Free.params));

%%

% R^2 for participant 3 is 0!!!!!!!
BW.params(3) = [];
Free.params(3) = [];

%%

[rho, p] = corr(BW.params, Free.params);

plot(BW.params, Free.params, 'r.');

for i = 1:numel(BW.params)
  text(BW.params(i) + 0.01, Free.params(i), num2str(i));
end

xlabel('Body/world');
ylabel('Free');

line(xlim, xlim);

title(sprintf('Rho: %.2f; p: %.2f; r2: %.2f', rho, p, r_squared(BW.params, Free.params)));
shg
