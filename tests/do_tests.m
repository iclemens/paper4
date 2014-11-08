function do_tests(mu)
    n = numel(mu);
    
    Y = mu;
    S = ones(12, 1) * (1:size(mu, 2));
    
    F1 = repmat([1; 2], 6, 1) * ones(1, size(mu, 2));
    F2 = [1; 1; 2; 2; 3; 3; 4; 4; 5; 5; 6; 6] * ones(1, size(mu, 2));
    
    a = rm_anova2( ...
        reshape(Y, n, 1), ...
        reshape(S, n, 1), ...
        reshape(F1, n, 1), ...
        reshape(F2, n, 1), ...
        {'Order', 'Condition'});
    
    disp(a);
    
    % Tests that show that body, world; free, world and free, body are different.
    X1 = mu(1:2,:); X2 = mu(3:4,:);
    [h, p, ci, stats] = ttest(X1(:), X2(:));
    fprintf('Body vs world: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
    
    X1 = mu(5:6,:); X2 = mu(7:8,:);
    [h, p, ci, stats] = ttest(X1(:), X2(:));
    fprintf('Free vs world: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
    
    X1 = mu(9:10,:); X2 = mu(11:12,:);
    [h, p, ci, stats] = ttest(X1(:), X2(:));
    fprintf('Free vs body: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
    
