function plot_rejected_traces(cfg, data)
  
  % Create plot of normalized eye movement signals (divide entire trace by sled distance)
  %  Panels for body, world, and none
  %  Rejected movements in gray, others in black
  
  angle_actual = [];
  
  for i_trial = 1:numel(data)
    trial = data(i_trial);
    for i_interval = 1:2;
    
      if trial.sled_distance(i_interval) ~= 0.1, continue; end;
      if ~strcmp(trial.fix_type{i_interval}, 'world'), continue; end;
    
      angle_actual(end + 1) = mean(diff( trial.angles{i_interval}([250 750], :)));    
    end
  end
  
  plot(angle_actual, '.');
  
  
  return;
  
  h = figure();
  
  for i_trial = 1:numel(data)
    for i_interval = 1:2
      trial = data(i_trial);
      N = length(trial.time);
      
      angle_ideal = atan2(trial.sled_distance(i_interval), 0.5);
      angle_actual = diff( trial.angles{i_interval}([250 750], :));
            
      angle_bl = (trial.angles{i_interval} - repmat(trial.angles{i_interval}(250, :), N, 1));      
      angle_norm = angle_bl ./ repmat(angle_ideal, N, 2);
      
      type = trial.fix_type{i_interval};
     
      %if trial.reject, continue; end;
      if abs(trial.sled_distance(i_interval)) < 0.05, continue; end;
      
      
      if ~strcmp(type, 'world'), continue; end;
      
      subplot(2, 3, trial.block.session + (i_interval - 1) * 3);
      
      
      hold on;
      
      if ~trial.reject
        plot(angle_ideal, angle_actual, 'b.');
      else
        plot(angle_ideal, angle_actual, 'r.');
      end
      
      %plot(trial.time, mean(angle_norm, 2));
      %ylim([-2 2]);
    end
  end
  
end