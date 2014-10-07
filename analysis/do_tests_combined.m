function do_tests_combined()
  psych_p3 = load('psychometrics_p3'); 
  psych_p4 = load('psychometrics_p4');  

  
  fprintf('Statistics for paper 3\n\n');
  
  first = psych_p3.mu(1:2:end, :);
  second = psych_p3.mu(2:2:end, :);
  
  [h, p, ci, stats] = ttest(first(:), second(:));
  fprintf('Order effect: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat);
  fprintf('\n');
  
  mu = 0.5 * (psych_p3.mu(1:2:end, :) + psych_p3.mu(2:2:end, :));
    
  % Tests that show that body, world; free, world and free, body are different.
  X1 = mu(1,:); X2 = mu(2,:);
  [h, p, ci, stats] = ttest(X1(:), X2(:));
  fprintf('Body vs world: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
  
  X1 = mu(3,:); X2 = mu(4,:);
  [h, p, ci, stats] = ttest(X1(:), X2(:));
  fprintf('Free vs world: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
  
  X1 = mu(5,:); X2 = mu(6,:);
  [h, p, ci, stats] = ttest(X1(:), X2(:));
  fprintf('Free vs body: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
  
  fprintf('\n\n');

  
  fprintf('Statistics for paper 4\n\n');
  
  first = psych_p4.mu(1:2:end, :);
  second = psych_p4.mu(2:2:end, :);
    
  [h, p, ci, stats] = ttest(first(:), second(:));
  fprintf('Order effect: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat);
  fprintf('\n');
    
  mu = 0.5 * (psych_p4.mu(1:2:end, :) + psych_p4.mu(2:2:end, :));
  
  X1 = mu(1, :); X2 = mu(2, :);
  [h, p, ci, stats] = ttest(X1(:), X2(:));
  fprintf('Body near vs body far: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
  
  X1 = mu(3, :); X2 = mu(4, :);
  [h, p, ci, stats] = ttest(X1(:), X2(:));
  fprintf('World near vs World far: %.2f (df = %d; t = %.2f)\n', p, stats.df, stats.tstat)
  
  