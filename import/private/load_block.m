function [trials, block_info] = load_block(experiment_id, block_id, experiment)
% [TRIALS, BLOCK_INFO] = LOAD_BLOCK(experiment_id, block_id, experiment)
%
% Loads EyeLink data and psychometric results for block BLOCK_ID
% in experiment EXPERIMENT_ID. Parameter EXPERIMENT should be
% 1 for the first experiment (paper 3) or 2 for the second experiment 
% (paper 4).
%
% TRIALS will be a cell array containing all trail data.
% BLOCK_INFO contain info about all trials in the block.
%
  
  global global_config;
  
  if nargin < 3
    if experiment_id < 10
      experiment = 1;
    else
      experiment = 2;
    end
  end

  session = global_config.sessions( ...
    global_config.sessions(:, 2) == experiment_id & ...
    block_id >= global_config.sessions(:, 4) & block_id <= global_config.sessions(:, 5), :);

  block_info = struct( ...
    'participant', session(1), ...
    'experiment', session(2), ...
    'session', session(3), ...
    'session_start', session(4), ...
    'block', block_id);

  eye = sprintf('block_%02d_eyelink.asc', block_id);
  res = sprintf('block_%02d_results.csv', block_id);

  res = sprintf('%s/ss%02d/%s', global_config.data_directory, experiment_id, res);
  eye = sprintf('%s/eyelink/ss%02d_eyelink/%s', global_config.cache_directory, experiment_id, eye);

  results = load_results(res);

  [eye_samples, eye_messages] = load_eyelink(eye);
  eye_samples = eye_samples';
  eye_samples(eye_samples(:) == 0) = NaN;

  % Extract trial start and stop messages
  trialid_msgs = eye_messages(strncmp(eye_messages(:, 2), 'TRIALID', 7), :);
  response_msgs = eye_messages(strncmp(eye_messages(:, 2), 'RESPONSE', 8), :);
  laser_msgs = eye_messages(strncmp(eye_messages(:, 2), 'WORM SELECT LASER ', 18), :);
  lasers = cellfun(@(x) str2double(x(end)), laser_msgs(:, 2));

  lasers = lasers(1:min(numel(response_msgs), numel(trialid_msgs)));
  
  % Due to a bug the first and second lasers should be identical
  if mod(numel(lasers), 2) ~= 0
    fprintf('Warning: odd number of laser messages\n');
  end
  
  if ~all(lasers(1:2:end) == lasers(2:2:end))
    fprintf('Warning: lasers do not match!\n');
  end
  
  if numel(lasers) ~= numel(trialid_msgs)
    fprintf('Warning: the amount of laser messages does not match the amount of start and stop messages\n');
  end
  
  if numel(trialid_msgs) ~= numel(response_msgs)
    fprintf('Warning: the amount of start and stop messages does not match in block %d, experiment %d!\n', block_id, experiment_id);    
  end

  % Check for missing trials
  results_trialids = [results{:, 2}];
  eyelink_trialids = cellfun(@(x) str2double(x(8:end)), trialid_msgs(:, 2));
  missing = setdiff(results_trialids, eyelink_trialids);

  if(~isempty(missing))
    fprintf('Warning: %d trial(s) are missing from block %d in experiment %d!\n', numel(missing), block_id, experiment_id);
  end

  common = intersect(results_trialids, eyelink_trialids);

  % Split data by trial
  trials = {};
  i = 1;

  for j = 1:numel(common)
    try
      trials{i} = struct();
      trials{i}.trial = common(j);
      trials{i}.block = block_info;
      
      % Determine trial start and stop time
      start_time = trialid_msgs{eyelink_trialids == common(j), 1};
      stop_time = response_msgs{eyelink_trialids == common(j), 1};

      % Parse results-file data
      result = results(results_trialids == common(j), :); 
      trial_info_res = parse_results(result);
      trials{i} = merge_trial_info(trials{i}, trial_info_res);  
      
      % Parse message data
      messages = eye_messages([eye_messages{:, 1}] >= start_time & [eye_messages{:, 1}] <= stop_time, :);
      
      if isempty(messages)
        error('No messages in trial %d\n', trials{i}.trial);        
      end
      
      trial_info_msg = parse_messages(messages, experiment);
      trials{i} = merge_trial_info(trials{i}, trial_info_msg);              

      trials{i}.messages = messages;
      
      ref_time = (-0.5:0.002:1.5)';
      time1 = ref_time + trials{i}.phases1(2);
      time2 = ref_time + trials{i}.phases2(2);
      
      for col = 1:4
        % Strip NaNs
        tmp_data = eye_samples(:, 1 + col);
        tmp_vals = ~isnan(tmp_data);
        
        % Use interpolation to align sample times
        trials{i}.samples{1, 1}(:, col) = interp1(eye_samples(tmp_vals, 1), tmp_data(tmp_vals), time1, 'pchip');
        trials{i}.samples{1, 2}(:, col) = interp1(eye_samples(tmp_vals, 1), tmp_data(tmp_vals), time2, 'pchip');
      end
      
      trials{i}.time = ref_time;

%     I used the following to check whether sample extraction works as expected.
%       clf; hold on;
%       plot(eye_samples(tmp_vals, 1) - time1(1), tmp_data(tmp_vals))
%       plot(time1 - time1(1), trials{i}.samples{1, 1}(:, col), 'g')
%       plot(time2 - time1(1), trials{i}.samples{1, 2}(:, col), 'r')
      
      i = i + 1;
    catch e
      disp(e.message);
      
      %for k = 1:numel(e.stack)
      %  fprintf('%d\t%s\t%s\n', e.stack(k).line, e.stack(k).name, e.stack(k).file);
      %end
      
      fprintf(2, 'Error processing trial %d of block %d\n', trials{i}.trial, block_info.block);
      trials(i) = [];
    end
  end
  
  % Compute inversion-score        
  score = 0;
  for i = 1:numel(trials)
    delta_diff = diff( abs(trials{i}.sled_distance) );
    score = score + (trials{i}.response - 0.5) * 2 * delta_diff;
  end

  if score < 0
    fprintf('Possible response inversion in block %d, score = %f\n', block_id, score);
  end
end
