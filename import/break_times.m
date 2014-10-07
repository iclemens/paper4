function break_times()

	global global_config;

  function [start_time, stop_time] = process_block(experiment_id, block_id)
    eye = sprintf('block_%02d_eyelink.asc', block_id);
    eye = sprintf('%s/eyelink/ss%02d_eyelink/%s', global_config.cache_directory, experiment_id, eye);
    
    [samples, msgs] = load_eyelink(eye);
    
    start_time = msgs{find(strcmp(msgs(:, 2), 'WORM ENABLE LASER'), 1), 1};
    stop_time = msgs{find(strcmp(msgs(:, 2), 'STOP'), 1, 'last'), 1};
  end
  
  
  breaks = [];
  
  nsessions = size(global_config.sessions(:, 2), 1);
  for i_session = 1:nsessions    
    fprintf('%.2f percent\n', i_session/nsessions*100);
    
    session = global_config.sessions(i_session, :);
    
    stop_time = process_block(session(2), session(4));
    
    for i_block = (session(4) + 1):session(5)
      [start_time, new_stop_time] = process_block(session(2), i_block);
      
      breaks(end + 1) = start_time - stop_time;
      
      stop_time = new_stop_time;
    end
    
    clf; plot(breaks);   
    fprintf('Mean +/- SD: %.2f +/- %.2f\n', median(breaks), std(breaks));
    drawnow;
  end
  
end