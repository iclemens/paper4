function test_import()
  
  global global_config;
    
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
  % Check whether entire file was read (i.e. number of lines match) %
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
  
  filename = fullfile(global_config.cache_directory, 'eyelink', 'ss01_eyelink', 'block_06_eyelink.asc');   
  
  line_count = 0;
  fid = fopen(filename, 'r');
  while ~feof(fid)
    line = strtrim(fgets(fid));

    if ~isempty(line) && line(1) ~= '*'
      line_count = line_count + 1;
    end
  end
  fclose(fid);
  
  [eye_samples, eye_messages] = load_eyelink(filename);
  
  n_samples = size(eye_samples, 2);  
  n_messages = size(eye_messages, 1);
  
  if line_count ~= (n_samples + n_messages)
    warning('Checking whether entire file was read: FAIL, got %d of %d lines.\n', n_samples + n_messages, line_count);
  else
    fprintf('Checking whether entire file was read: ok, got %d lines.\n', line_count);
  end
  
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
  % Checking timestamp and contents of two messages and a sample %
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
  
  filename = fullfile(global_config.cache_directory, 'eyelink', 'ss04_eyelink', 'block_44_eyelink.asc'); 
  [eye_samples, eye_messages] = load_eyelink(filename);
  
  if eye_messages{25, 1} ~= 27225.997 || ...
     ~strcmp(eye_messages{25, 2}, 'TRIALID 314') || ...
     eye_messages{45, 1} ~= 27231.856 || ...
     ~strcmp(eye_messages{45, 2}, 'SLED MOVE 153333 1000')
    warning('Checking timestamp and contents of two known messages: FAIL, do not match');
  end
  
  if ~all(eye_samples(:, eye_samples(1, :) == 27310.216) == [27310.216; 0; 0; 10808; 14033])
    warning('Checking sample timestamp and values: FAIL, do not match');
  end
  
  
  % %%%
  %
  % %%%
  
  
%   filename = fullfile(global_config.cache_directory, 'eyelink', 'ss01_eyelink', 'block_06_eyelink.asc');
%   [eye_samples, eye_messages] = load_eyelink(filename);
%   [trial, block_info] = load_block(1, 6);
%   
%   trial_msg_idx = find(strcmp(eye_messages(:, 2), 'TRIALID 32'));  
%   stop_msg_idxs = find(strcmp(eye_messages(:, 2), 'STOP'));  
%   stop_msg_idx = stop_msg_idxs(find(stop_msg_idxs > trial_msg_idx, 1));
%   
%   trial_msgs = eye_messages(trial_msg_idx:stop_msg_idx, :);
%   move_msgs = trial_msgs(strncmp(trial_msgs(:, 2), 'SLED MOVE', 9), :);
%   
%   samples = eye_samples(:, eye_samples(1, :) >= move_msgs{1, 1} & eye_samples(1, :) <= (move_msgs{1, 1} + 1));
%   
%   
%   trial_samples = eye_samples(:, eye_samples(1, :) >= trial_msgs{1, 1} & eye_samples(1, :) <= trial_msgs{end, 1});
%   
%   %plot(samples([2 4], :)', 'b')
%   %plot(trial{2}.samples{1}(250:750, [1 3]), 'r--')
%   hold on;
%   plot(trial_samples(1, :), trial_samples(2, :));
%   plot([1 1] * move_msgs{1, 1}, ylim, 'k--');
%   plot([1 1] * move_msgs{1, 1} + 1, ylim, 'k--');
%   
%   plot([1 1] * move_msgs{2, 1}, ylim, 'k--');
%   plot([1 1] * move_msgs{2, 1} + 1, ylim, 'k--');
%     
  
  