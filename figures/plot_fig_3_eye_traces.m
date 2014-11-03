function plot_fig_3_eye_traces(experiment)
  global global_config;
  
  % Settings
  if nargin < 1, experiment = 1; end
  participant = 8;
  tracespercondition = 20;
  eye_mode = 'gain';
  
  save_result = 1;
  colors = color_scheme(2);
  
  if experiment == 1
    colors = [colors(1, :); colors(3, :); 0 0 0];
  end
  
  
  % % % % % % % %`
  % Common part %
  % % % % % % % %
  
  
  % Load trials (for traces)
  tmp = load(sprintf('%s/cleaned_%02d.mat', ...
    global_config.cache_directory, participant + 10 * (experiment - 1)));
  trials = tmp.data;
  
  % Load eye movement gains
  if experiment == 1
    tmp = load(fullfile(global_config.cache_directory, 'psychometrics_p3.mat'));
  else
    tmp = load(fullfile(global_config.cache_directory, 'psychometrics_p4.mat'));
  end
  
  if strcmp(eye_mode, 'disp')
    eye_simple = tmp.eye_disp_simple;
    eye_extended = tmp.eye_disp_extended;
    eye_simple_2nd = tmp.eye_disp_simple_2nd;
  else
    eye_simple = tmp.eye_gain_simple;
    eye_extended = tmp.eye_gain_extended;
    eye_simple_2nd = tmp.eye_gain_simple_2nd;
  end
  
  % Determine which conditions to show
  if experiment == 1
    conditions = global_config.conditions_p3;
  else
    conditions = global_config.conditions_p4;
  end
  
  conditions = vertcat(conditions{:});
  conditions = conditions([conditions{:, 5}] == 1, 1:4);
  if experiment == 1
    conditions = conditions(1:(size(conditions, 1)/2), 1:2);
  else
    conditions = conditions(:, 1:2);
  end
  nconditions = size(conditions, 1);
  
  gains_modes = {'combined'};
  %gains_modes{end + 1} = 'separate';
  
  for i = 1:numel(gains_modes)
    gains_mode = gains_modes{i};
    
    figure(i);
    clf;
    
    subplot(1, 2, 1);
    traces_panel(gca);
    subplot(1, 2, 2);
    gains_panel(gca);
    
    
    % Set figure style
    orient(gcf, 'Portrait');
    
    set(gcf, ...
      'Units', 'centimeters', ...
      'PaperUnits', 'centimeters', ...
      'Position', [0 0 17.6 6], ...
      'PaperPosition', [0 0 17.6 6]);
    
    if save_result
      if experiment == 1
        outputFile = fullfile(global_config.figure_directory_p3, 'paper3_figure3.eps');
      else
        outputFile = fullfile(global_config.figure_directory_p4, 'paper4_figure3.eps');
      end
      fprintf('Writing %s\n', outputFile);
      export_fig('-transparent', '-nocrop', '-eps', outputFile);
    end
  end
  
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  
  
  function traces_panel(handle_axes)
    cla(handle_axes);
    hold(handle_axes, 'on');
    
    % Counts how many traces have been plotted per condition
    count = zeros(nconditions, 1);
    i_interval = 1;
    
    % Plot traces
    for i_trial = 1:length(trials)
      trial = trials(i_trial);
      i_condition = determine_condition(trial, i_interval);
      direction = sign(trial.sled_distance(i_interval));
      
      if trial.sled_distance(i_interval) ~= 0.1, continue; end
      
      trace = direction * trial.angles(:, i_interval);
      
      if experiment == 1
        if any(trace > 0.3), continue; end;
        if i_condition == 2 && trace(750) > 0.27, continue; end;
        if i_condition == 1 && trace(750) > 0.04, continue; end;
        if any(trace < -0.04), continue; end;
      else
        if i_trial == 282, continue; end;
      end
      
      if count(i_condition) > tracespercondition, continue; end;
      count(i_condition) = count(i_condition) + 1;
      
      handle_trace = plot(trial.time, trace);
      
      % Set style of trace
      set(handle_trace, 'LineWidth', 1, 'Color', colors(i_condition, :));
    end
    
    % Ideal body and world traces
    t = linspace(-1, 1, 100);
    sled_position = zeros(size(t));
    t_eqn = t(t > 0) / 2;
    
    sled_position(t > 0) = 800 * t_eqn.^3 - 2400 * t_eqn.^4 + 1920 * t_eqn.^5;
    
    if experiment == 2
      handle_ideal_world_near = line(t, atan2(sled_position, 200));
    end
    
    handle_ideal_world = line(t, atan2(sled_position, 50));
    handle_ideal_body = line([-5 1], [0 0]);
    
    
    % Vertical lines
    handle_vlines = [
      line([0 0], [-5 5]);
      line([1 1], [-5 5])
      ];
    
    % Period labels
    handle_period_labels = [
      text(-0.1, -0.05, 'Fix');
      text(0.5, -0.05, 'Reference movement');
      ];
    
    
    % % % % % %
    % Styling %
    % % % % % %
    
    % Axes
    set(handle_axes, ...
      'FontSize', 10, ...
      'XTick', [0 0.5 1], ...
      'YTick', deg2rad([-5 0 5 10 15 20]), ...
      'YTickLabel', {-5 0 5 10 15 20});
    
    xlim(handle_axes, [-0.2 1.2]);
    ylim(handle_axes, deg2rad([-5 15]));
    xlabel(handle_axes, 'Time (s)', 'FontSize', 12);
    
    set(handle_axes, 'XTickLabel', {0.5 1 1.5});
    ylabel(handle_axes, 'Angle (deg)', 'FontSize', 12);
    
    % Ideal lines
    set(handle_ideal_body, 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 2);
    set(handle_ideal_world, 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 2);
    
    if experiment == 2
      set(handle_ideal_world_near, 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 2);
    end
    
    % Vertical lines
    for handle = handle_vlines
      set(handle, 'Color', 'k', 'LineWidth', 1);
    end
    
    % Period labels
    for handle = handle_period_labels
      set(handle, 'HorizontalAlignment', 'Center', 'FontSize', 7);
    end
    
  end
  
  
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  
  
  function h = errorbar(x, y, yl, yh, varargin)
    wd = 0.10;
    h = [ ...
      line([x x], [y - yl y + yh], varargin{:});
      line([x - wd x + wd], [y - yl y - yl], varargin{:});
      line([x - wd x + wd], [y + yh y + yh], varargin{:});
      ];
  end
  
  
  function gains_panel(handle_axes)
    cla(handle_axes);
    hold(handle_axes, 'on');
    
    h_ideal_body = line([0 10], [0 0]);
    if strcmp(eye_mode, 'disp')
      h_ideal_world = line([0 10], [1 1] * atan2(0.1, 0.5));
      
      if experiment == 2
        h_ideal_world_far = line([0 10], [1 1] * atan2(0.1, 2.0));
      end
      
    else
      h_ideal_world = line([0 10], [1 1]);
    end
    
    %eye_gain_simple
    %body 0.5 body 2.0 world 0.5 world 2.0
    
    %
    % BN - (bf)
    % BF - (bn)
    %
    % WN - (wf)
    % WF - (wn)
    
    
    if strcmp(gains_mode, 'separate')
      % Plot three/four bars for each type
      for s = 1:8
        if experiment == 1
          serrorbar(s - 0.1, s, 2,    'Color', colors(2, :), 'LineWidth', 2);  % WORLD - (body/none)
          merrorbar(s - 0.1, s, 2, 2, 'Color', colors(1, :));                  % world - BODY
          merrorbar(s - 0.1, s, 4, 2, 'Color', colors(3, :));                  % world - NONE
          
          serrorbar(s + 0.0, s, 1,    'Color', colors(1, :), 'LineWidth', 2);  % BODY - (world/none)
          merrorbar(s + 0.0, s, 5, 2, 'Color', colors(3, :));                  % body - NONE
          merrorbar(s + 0.0, s, 1, 2, 'Color', colors(2, :));                  % body - WORLD
          
          serrorbar(s + 0.1, s, 3,    'Color', colors(3, :), 'LineWidth', 2);  % NONE - (world/body)
          merrorbar(s + 0.1, s, 3, 2, 'Color', colors(2, :));                  % none - WORLD
          merrorbar(s + 0.1, s, 6, 2, 'Color', colors(1, :));                  % none - BODY
        else
          serrorbar(s - 0.15, s, 1, 'Color', colors(1, :), 'LineWidth', 2); % BN -
          serrorbar(s - 0.05, s, 2, 'Color', colors(2, :), 'LineWidth', 2); % BF -
          serrorbar(s + 0.05, s, 3, 'Color', colors(3, :), 'LineWidth', 2); % WN -
          serrorbar(s + 0.15, s, 4, 'Color', colors(4, :), 'LineWidth', 2); % WF -
          
          merrorbar(s - 0.15, s, 1, 2, 'Color', colors(2, :)); % bn - BF
          merrorbar(s - 0.05, s, 2, 2, 'Color', colors(1, :)); % bf - BN
          merrorbar(s + 0.05, s, 3, 2, 'Color', colors(4, :)); % wn - WF
          merrorbar(s + 0.15, s, 4, 2, 'Color', colors(3, :)); % wf - WN
        end
      end
    elseif strcmp(gains_mode, 'combined')
      cdpl = [-0.05 0.05 0 0];
      % Only plot one bar per type (old-style figure)
      for c = 1:nconditions
        for s = 1:8
          terrorbar(s + cdpl(c), s, c, 'Color', colors(c, :));
        end
        taerrorbar(9 + cdpl(c), c, 'Color', colors(c, :));
      end
    else
      error('Invalid mode');
    end
    
    % Axes styling
    if strcmp(eye_mode, 'gain')
      ylabel(handle_axes, 'Normalized eye position', 'FontSize', 12);
    else
      ylabel(handle_axes, 'Normalized angle (deg)', 'FontSize', 12);
    end
    xlabel(handle_axes, 'Participant', 'FontSize', 12);
    xlim([0 10]);
    
    set(gca, 'XTickLabel', {'1', '2', '3', '4', '5', '6', '7', '8', 'Avg'});
    
    if strcmp(eye_mode, 'disp')
      ticks = [-5 0 5 10 15];
      set(handle_axes, ...
        'YTick', ticks / 180 * pi, ...
        'YTickLabel', ticks);
      ylim([-5 15] / 180 * pi);
    else
      set(handle_axes, 'YTick', [0 0.5 1]);
      ylim([-0.5 1.5]);
    end
    
    set(handle_axes, ...
      'FontSize', 10, ...
      'XTick', 1:9);
    
    % Style ideal gain lines
    set(h_ideal_body, 'Color', colors(1, :), 'LineStyle', '--');
    set(h_ideal_world, 'Color', colors(2, :), 'LineStyle', '--');
    
    if experiment == 2
      if ~strcmp(eye_mode, 'gain')
        set(h_ideal_world_far, 'Color', colors(4, :), 'LineStyle', '--');
      end
      set(h_ideal_world, 'Color', colors(3, :), 'LineStyle', '--');
    end
    
  end
  
  
  function cond = determine_condition(trial, interval)
    cond = find(strcmp(conditions(:, 1), trial.fix_type{interval}) & [conditions{:, 2}]' == trial.fix_distance(interval));
  end
  
  function serrorbar(x, p, c, varargin)
    gain = eye_simple.gain(p, c);
    low = eye_simple.low(p, c);
    high = eye_simple.high(p, c);
    
    errorbar(x, gain, low, high, varargin{:});
  end
  
  function terrorbar(x, p, c, varargin)
    gain = eye_simple_2nd.gain(p, c);
    low = eye_simple_2nd.low(p, c);
    high = eye_simple_2nd.high(p, c);
    
    errorbar(x, gain, low, high, varargin{:});
  end
  
  function taerrorbar(x, c, varargin)
    gain = mean(eye_simple_2nd.gain(:, c));
    low = std(eye_simple_2nd.gain(:, c)) / sqrt(8);
    high = std(eye_simple_2nd.gain(:, c)) / sqrt(8);
    
    errorbar(x, gain, low, high, varargin{:});
  end
  
  function merrorbar(x, p, c, i, varargin)
    gain = eye_extended.gain(p, c, i);
    low = eye_extended.low(p, c, i);
    high = eye_extended.high(p, c, i);
    
    errorbar(x, gain, low, high, varargin{:});
  end
end
