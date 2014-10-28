
m1 = 0.1;
m2 = 0.15;

u1 = 0.05;
u2 = 0.05;

X = linspace(0.0, 0.3, 100);

% Plot example trial
subplot(2, 1, 1); cla; hold on; xlim([0. 0.3]);
plot(X, normpdf(X, m1, u1), 'r');
plot(X, normpdf(X, m2, u2), 'b');

p = mean(normrnd(m2, u2, 5000, 1) > normrnd(m1, u1, 5000, 1));
title(sprintf('P(longer): %.2f', p));

subplot(2, 1, 2); cla; hold on; xlim([0 0.3]);
cs = cumsum(normpdf(X, m1, u1) .* normpdf(X, m2, u2));
plot(X, cs ./ max(cs));

%%

probe = [0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15];

v2 = sqrt(u1 .^ 2 + u2 .^ 2);

for i = 1:numel(probe)
    p(i) = mean(normrnd(probe(i), u2, 50000, 1) > normrnd(0.1, u1, 50000, 1));
    q(i) = mean(normrnd(probe(i) - 0.1, v2, 50000, 1) > 0);
    
    r(i) = normcdf(probe(i) - 0.1, 0, v2);
    
end

[p; q; r]
