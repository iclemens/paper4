function load_and_preprocess(experiment)
  global global_config;
  
  if nargin < 1 || experiment == 1
    experiments = 1:8;
  else
    experiments = 11:18;
  end
  
  
  main();
  
  
  function main()            
    % Create directory for preprocessing figures
    cal_figure_directory = [global_config.cache_directory '/figs_calibration'];
    if ~exist(cal_figure_directory, 'dir'), mkdir(cal_figure_directory); end;
    
    % Load data for all experiments and run preprocessing.
    for experiment_id = experiments
      sessions = global_config.sessions(...
        global_config.sessions(:, 2) == experiment_id, :);
      data = [];
      
      for i_session = 1:size(sessions, 1)
        fprintf('Participant %d session %d\n', experiment_id, i_session);
        
        % Load calibration function
        cal = load_calibration(experiment_id, sessions(i_session, 4), 'plot', cal_figure_directory);
        local_config = struct('experiment_id', experiment_id, 'cal', cal);
        
        % Process all blocks belonging to this session and add them to data
        for block_id = sessions(i_session, 4):sessions(i_session, 5)
          [trials, block_info] = load_block(experiment_id, block_id);
          
          for i_trial = 1:length(trials)
            trials{i_trial} = rmfield(trials{i_trial}, {'phases1', 'phases2', 'messages'});
            trials{i_trial} = calibrate(local_config, trials{i_trial});
            
            % Add reject to mark rejected trials
            trials{i_trial}.reject = false;
          end
          
          if isempty(data)
            data = trials;
          else
            data = [data, trials];
          end
        end
      end
      
      data = [data{:}];
      
      % Save data to cache directory
      save( ...
        sprintf('%s/preproc_%02d', global_config.cache_directory, experiment_id), ...
        'data');
    end
  end
  
  
  function trial = calibrate(cfg, trial)
    time = trial.time;
    cfg.frequency = 1 / (time(2) - time(1));
    
    for i_interval = 1:numel(trial.samples)
      samples = trial.samples{1, i_interval};      
      angles = cfg.cal.calibration_fcn(samples);
      
      pos_l = ed_compvelacc(cfg, angles(:, 1:2));
      pos_r = ed_compvelacc(cfg, angles(:, 3:4));
      
      trial.angles(:, i_interval) = 0.5 * (pos_r(:, 1) + pos_l(:, 1));
      trial.vergence(:, i_interval) = pos_r(:, 1) - pos_l(:, 1);
    end
  end

  
end