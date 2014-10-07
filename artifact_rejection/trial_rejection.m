function trial_rejection(cfg)
    %
    % Performs artifact trial rejection
    %
    %  cfg is a struct with fields:
    %   experiment_ids - List of experiments/participants to process
    %                    use [1:8 11:18] to process everything.
    %

    
  global global_config;
  
  deg2rad = @(angle) angle / 180 * pi;
  
  
  function cal_func = create_cal_func(data)    
    sel_world = arrayfun(@(t) strcmp(t.fix_type{1}, 'world') & t.fix_distance(1) == 0.5, data);
    sel_body = arrayfun(@(t) strcmp(t.fix_type{1}, 'body'), data);
    
    slope_body = compute_slope(data(sel_body));
    cal_func = @(x, d) (x - data(1).time * d * slope_body);
    
    tmp = apply_cal_func(data, cal_func);
    slope_world = compute_slope(tmp(sel_world));
    cal_func = @(x, d) (x - data(1).time * d * slope_body) / slope_world;
    
    % Test calibration function
    data = apply_cal_func(data, cal_func);
    slope_world_after = compute_slope(data(sel_world));
    slope_body_after = compute_slope(data(sel_body));
    
    fprintf('Test calibration => Slope body: %.2f (%.2f); world: %.2f (%.2f)\n', ...
      slope_body_after, slope_body, slope_world_after, slope_world);
  end
  
  
  function [slope, X, Y] = compute_slope(tmp)    
    tmp = tmp([tmp.reject] == 0);
    X = arrayfun(@(t) atan2(t.sled_distance(1), 0.5), tmp)';
    Y = arrayfun(@(t) diff( t.angles([251 751], 1)), tmp)';
    slope = regress(Y, X);
  end
  
  
  %         for i_interval = intervals
  %           selection = arrayfun(@(t) ...
  %             strcmp(t.fix_type{i_interval}, conditions{i_conditions, 1}) && ...
  %             t.fix_distance(i_interval) == conditions{i_conditions, 2} , data);
  %
  %           X = [X; arrayfun(@(t) atan2(t.sled_distance(i_interval), 0.5), data(selection))'];
  %           Y = [Y; arrayfun(@(t) diff(t.angles([250 750], i_interval)), data(selection))'];
  %         end
  %
  %         [mn, bint] = regress(Y, X);
  
  
  function data = apply_cal_func(data, cal_func)
    for i_trial = 1:numel(data)
      for i_interval = 1:2
        data(i_trial).angles(:, i_interval) = data(i_trial).angles(:, i_interval) - data(i_trial).angles(250, i_interval);
        d = atan2(data(i_trial).sled_distance(i_interval), 0.5);
        data(i_trial).angles(:, i_interval) = cal_func(data(i_trial).angles(:, i_interval), d);
      end
    end
  end
  
  
  function [data, count] = mark_bad_intervals(data, interval)
    type = data(1).fix_type{interval};
    
    % Number of standard deviations
    if strcmp(type, 'world')
      threshold = 0.90;
    elseif strcmp(type, 'none')
      threshold = 0.99;
    else
      threshold = 0.975;
    end
    
    angle_ideal = arrayfun(@(t) atan2(t.sled_distance(interval), 0.5), data)';
    angle_actual = arrayfun(@(t) diff( t.angles([251 751], interval)), data)';
    
    [~, ~, r] = regress(angle_ideal, angle_actual);
    r = abs(r);
    C = cov(r);
    
    md = ( (r - median(r)) .* inv(cov(r)) .* (r - median(r)) );
    bad_ones = chi2cdf(md, 1) > threshold;
    
    % Enable / disable plot
    plot(md, '.');
    x = 1:length(r);
    plot(x(bad_ones), md(bad_ones), 'ro');
    
    count = sum(bad_ones);
    
    spd = zeros(1, numel(data));
    for t = 1:numel(data)
      angles = data(t).angles(250:750, interval);
      spd(t) = nanmax(nanmax(diff(angles) / 0.002));
    end
    
    for t = 1:numel(data)
      data(t).reject = data(t).reject | bad_ones(t) | spd(t) > 6 * nanstd(spd);
    end
  end
  
  
  function [data, rate] = mark_bad_trials(local_config, data, experiment)
    
    % Add fields to struct to avoid errors in the future.
    for t = 1:numel(data)
      data(t).reject = false;
    end
    
    % Mark bad trials
    if experiment == 1
      types = {'world', 0.5; 'body', 0.5; 'none', 0.5};
    else
      types = {'world', 0.5; 'world', 2.0; 'body', 0.5; 'body', 2.0};
    end
    
    ntypes = size(types, 1);
    count = zeros(ntypes, ntypes);
    
    session_ids = arrayfun(@(t) t.block.session, data);
    h = figure();
    
    clf; hold on;
    col = 'rgb';
    
    % Recalibrate based on slopes in world and body
    for session = unique(session_ids)
      selection = session_ids == session;      
      cal_func = create_cal_func(data(selection));
      data(selection) = apply_cal_func(data(selection), cal_func);     
    end
    
    
    % Perform analysis
    for session = unique(session_ids)
      for i_type = 1:size(types, 1)
        selection = (session_ids == session) & ...
          arrayfun(@(t) strcmp(t.fix_type{1}, types(i_type, 1)) && ...
          t.fix_distance(1) == types{i_type, 2}, data);
        
        %slope = compute_slope(data(selection));
        %fprintf('Slope %s: %.2f\n', types{i_type}, slope);
        
        subplot(ntypes, ntypes, (i_type - 1) * ntypes + i_type); hold on;
        title(sprintf('%s-', types{i_type}));
        
        [data(selection), cnt] = mark_bad_intervals(data(selection), 1);
        count(i_type, i_type) = count(i_type, i_type) + cnt;
        title(sprintf('%d', count(i_type, i_type)));
        
        % Second interval
        for j_type = 1:size(types, 1)
          if i_type == j_type, continue; end;
          
          selection = (session_ids == session) & ...
            arrayfun(@(t) all(strcmp(t.fix_type, types([i_type j_type]))) && ...
            all(t.fix_distance == [types{[i_type, j_type], 2}]), data);
          
          subplot(ntypes, ntypes, (i_type - 1) * ntypes + j_type); hold on;
          
          if sum(selection) == 0
            title('');
            axis(gca, 'off');
            continue;
          end
          
          title(sprintf('%s-%s', types{i_type}, types{j_type}));
          
          [data(selection), cnt] = mark_bad_intervals(data(selection), 2);
          count(i_type, j_type) = count(i_type, j_type) + cnt;
          title(sprintf('%d', count(i_type, j_type)));
        end
      end
    end       
    
    
    % Recalibrate based on slopes in world and body (after trial rejection)
    for session = unique(session_ids)
      selection = session_ids == session;      
      cal_func = create_cal_func(data(selection));
      data(selection) = apply_cal_func(data(selection), cal_func);     
    end
    
    
    filename = sprintf('%s/reject_graph_%02d.eps', local_config.figure_directory, local_config.experiment_id);
    print(h, filename, '-depsc2');
    
    
    % Remove fields that are no longer required
    data = rmfield(data, 'samples');
    
    disp('Rejection matrix:');
    disp(count ./ numel(data) * 100);
    
    rate = sum(arrayfun(@(t) t.reject ~= 0, data)) / numel(data);
    
    fprintf('Rejected %.2f%% (%.2f)\n', rate * 100, 100 * nansum(count(:)) ./ numel(data));
    
    close(h);
  end
  
  
  function main(cfg)
    if ~isfield(cfg, 'experiment_ids'), cfg.experiment_ids = 1:8; end;
    
    local_config = struct();
    
    % Define and create figure directory
    local_config.figure_directory = fullfile(global_config.cache_directory, 'figs_trial_rejection');
    mkpath(local_config.figure_directory);
    
    rate = nan(1, max(cfg.experiment_ids));
    
    for experiment_id = cfg.experiment_ids
      local_config.experiment_id = experiment_id;
      
      fprintf('Participant %d\n', experiment_id);
      
      if experiment_id < 10
        experiment = 1;
      else
        experiment = 2;
      end
      
      data = [];
      load(sprintf('%s/preproc_%02d', global_config.cache_directory, experiment_id));
      [data, rate(experiment_id)] = mark_bad_trials(local_config, data, experiment);
            
      output_filename = sprintf('%s/cleaned_%02d', global_config.cache_directory, experiment_id);
      save(output_filename, 'data');
      
      %plot_rejected_traces(local_config, data);
      
    end
    
    fprintf('Rejected %.2f%% of all trials\n', nanmean(rate)*100);
  end
  
  main(cfg);
end
