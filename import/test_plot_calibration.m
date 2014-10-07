function test_plot_calibration(data)
  
  
  ahead = [];
  left = [];
  right = [];  

  for i_trial = 1:numel(data)
    trial = data(i_trial);
    
    ahead(end + 1, :) = [i_trial mean(trial.samples{1}(250, [1 3]))];
    
    if abs(trial.sled_distance(1)) ~= 0.1, continue; end;
    if ~strcmp(trial.fix_type{1}, 'world'), continue; end;
    
    if trial.sled_distance(1) < 0
      left(end + 1, :) = [i_trial mean(trial.samples{1}(750 + 30, [1 3]))];
    else
      right(end + 1, :) = [i_trial mean(trial.samples{1}(750 + 30, [1 3]))];
    end    
  end
  
  clf; hold on;
  
  plot(ahead(:, 1), ahead(:, 2), 'k.-');  
  plot(left(:, 1), left(:, 2), 'b.-');
  plot(right(:, 1), right(:, 2), 'r.-');
