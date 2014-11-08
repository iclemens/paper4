function trial_info = parse_messages(messages, experiment)
% Converts eyelink messages into a trial_info structure.
%
% Note that this information is also contained within the
% results CSV file. By loading it from both files, we can
% later check for anomalies in the data.
%

  % Extract movement distance from messages  
  msg_position_1 = sscanf(messages{strncmp(messages(:, 2), 'SLED POSITION', 13), 2}, 'SLED POSITION %d');
  msg_position_2 = sscanf(messages{find(strncmp(messages(:, 2), 'SLED MOVE', 9), 1, 'first'), 2}, 'SLED MOVE %d');
  msg_position_3 = sscanf(messages{find(strncmp(messages(:, 2), 'SLED MOVE', 9), 1, 'last'), 2}, 'SLED MOVE %d');

  trial_info.sled_distance = [ ...
    msg_position_2(1) - msg_position_1, ...
    msg_position_3(1) - msg_position_2(1)] / 1000.0 / 1000.0;

  % Extract fixation distance in first interval
  select = messages{find(strncmp(messages(:, 2), 'WORM SELECT LASER', 17), 1, 'first'), 2};
  laser_info = sscanf(select, 'WORM SELECT LASER %d %d');
  trial_info.fix_distance = [laser_info(1) / 1000.0 NaN];
  
  % Extract laser info for second interval
  select = messages{find(strncmp(messages(:, 2), 'WORM SELECT LASER', 17), 1, 'last'), 2};    

  % Verify that the laser is (not) being disabled depending on trial type.
  %  TODO

  % Extract information about phases (fixation, movement)
  msg_enable = messages(strcmp(messages(:, 2), 'WORM ENABLE LASER'), :);
  msg_sled = messages(strncmp(messages(:, 2), 'SLED MOVE', 9), :);
  msg_disable = messages(strcmp(messages(:, 2), 'WORM DISABLE LASER'), :);

  trial_info.fix_type = {NaN NaN};
  
  for interval = 1:2
    field = sprintf('phases%d', interval);
    trial_info.(field) = [ ...
      msg_enable{interval, 1} msg_sled{interval, 1} ...
      msg_disable{find([msg_disable{:, 1}] > msg_sled{interval, 1}, 1), 1}];
  
    tmp = [msg_disable{:, 1}] >= msg_enable{interval, 1} & [msg_disable{:, 1}] <= msg_sled{interval, 1};
    
    if any(tmp)
      trial_info.fix_type{interval} = 'none';    
    elseif interval == 1
      if laser_info(2) == 2 || laser_info(2) == 3
        trial_info.fix_type{interval} = 'body';
      elseif laser_info(2) == 0 || laser_info(2) == 1
        trial_info.fix_type{interval} = 'world';
      else
        error('Unknown laser');
      end
    end    
  end
  
  if experiment == 1
    % Infer type of interval 2... we don't know in case
    %  the none condition was presented in the first interval
    if ~strcmp(trial_info.fix_type{1}, 'none') && any(isnan(trial_info.fix_type{2}))
      if strcmp(trial_info.fix_type{1}, 'body')
        trial_info.fix_type{2} = 'world';
      else
        trial_info.fix_type{2} = 'body';
      end    
    end
    
    trial_info.fix_distance(2) = trial_info.fix_distance(1);
  elseif experiment == 2
    trial_info.fix_type{2} = trial_info.fix_type{1};
    
    if trial_info.fix_distance(1) == 0.5
      trial_info.fix_distance(2) = 2.0;
    else
      trial_info.fix_distance(2) = 0.5;
    end
  end
  
  % Verify phase durations
  phase1_diff = diff(trial_info.phases1);
  phase2_diff = diff(trial_info.phases2);
  
  phase1_check = abs(phase1_diff - [0.5 1.0]);
  phase2_check = abs(phase2_diff - [0.5 1.0]);
  isi = abs(abs(trial_info.phases2(1) - trial_info.phases1(3)) - 1.750);

  if any(phase1_check > 0.03)    
    error('parse_message:timing', 'Interval 1 timing not correct. Fixation: %.2fs. Movement: %.2fs', phase1_diff(1), phase1_diff(2));
  end
  
  if any(phase2_check > 0.03)
    error('parse_message:timing', 'Interval 2 timing not correct. Fixation: %.2fs. Movement: %.2fs', phase2_diff(1), phase2_diff(2));
  end
  
  if isi > 0.1
    error('parse_message:timing', 'Interval between movements is not correct (%.2f instead of 1.75s)', isi);
  end  
end
