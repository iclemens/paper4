
figure(1);
subplot(4, 2, 1); Rsq = plot_p3(model('emv', '12') ); title(sprintf('emv-12 %.2f', Rsq));
subplot(4, 2, 2); Rsq = plot_p3(model('emv', 'rp') ); title(sprintf('emv-rv %.2f', Rsq));
subplot(4, 2, 3); Rsq = plot_p3(model('hfd', '12') ); title(sprintf('hfd-12 %.2f', Rsq));
subplot(4, 2, 4); Rsq = plot_p3(model('hfd', 'rp') ); title(sprintf('hfd-rv %.2f', Rsq));

subplot(4, 2, 5); Rsq = plot_p4(model('emv', '12') ); title(sprintf('emv-12 %.2f', Rsq));
subplot(4, 2, 6); Rsq = plot_p4(model('emv', 'rp') ); title(sprintf('emv-rv %.2f', Rsq));
subplot(4, 2, 7); Rsq = plot_p4(model('hfd', '12') ); title(sprintf('hfd-12 %.2f', Rsq));
subplot(4, 2, 8); Rsq = plot_p4(model('hfd', 'rp') ); title(sprintf('hfd-rv %.2f', Rsq));

% 0.48 fitted Rsq

%%



%%
% 0.35 best ssq


range = linspace(0, 0.4, 11);
for i = 1:numel(range)
    subplot(4,3,i);
    rsq = plot_p3(model('emv', '12', range(i)) );
    title(sprintf('%.2f, %.2f', range(i), rsq));
end


%%

clc;

N = 11;
range = linspace(0, 0.4, N);
params = zeros(N, 8);

for i = 1:numel(range)
    output = model('hfd', 'rp', NaN, range(i));
    Rsq = plot_p3(output);

    params(i, :) = [output.output_p3.fit];
end

%%

tmp = model('hfd', 'rp', NaN);
hfd_params = vertcat(tmp.output_p3.fit);

tmp = model('emv', 'rp', NaN);
emv_params = vertcat(tmp.output_p3.fit);

tmp = model('wgt', 'rp', NaN);
wgt_params = vertcat(tmp.output_p3.fit);

% At near EMV have weight of 0.06 at far EMV has weight of 0.75
% Therefore, eye movements the weight associated to the eye movements (or the absence thereof) increases with distance.
