function plot_fig_2b_all(experiment, mode34)
  global global_config;

  % Settings
  if nargin < 1, experiment = 1; end
  save_result = 1;

  
  % Load data
  if experiment == 1
    tmp = load(fullfile(global_config.cache_directory, 'psychometrics_p3.mat'));        
    mu = tmp.mu;
  else
    tmp = load(fullfile(global_config.cache_directory, 'psychometrics_p3.mat'));        
    mu = tmp.mu;
  end 
  
  % Combine mu-values
  mu = 0.5 * (mu(1:2:end, :) + mu(2:2:end, :));
  colors = color_scheme(experiment);
  
  if experiment == 1
    labels = {'BW', 'WB', 'FW', 'WF', 'BF', 'FB'};
  else
    labels = {'B(NF)', 'B(FN)', 'W(NF)', 'W(FN)'};
  end
  
  % Create plots
  if ~mode34
    figure(1);
    clf;
    rows = 1;
    ofs = 0;
  else
    if experiment == 1
      rows = 2;
      ofs = 3;
    elseif experiment == 2
      rows = 2;
      ofs = 2;
    end;
  end

  if experiment == 1
    bar_panel(subplot(rows, 3, ofs + 1), [1 2]);
    bar_panel(subplot(rows, 3, ofs + 2), [3 4]);
    bar_panel(subplot(rows, 3, ofs + 3), [5 6]);  
    
    subplot(rows, 3, ofs + 2); ylabel(' ');
    subplot(rows, 3, ofs + 3); ylabel(' ');
  else    
    bar_panel(subplot(rows, 2, ofs + 1), [1 2]);
    bar_panel(subplot(rows, 2, ofs + 2), [3 4]);
    
    subplot(rows, 2, ofs + 2); ylabel(' ');
  end

  % Set figure style
  orient(gcf, 'Portrait');
  set(gcf, ...
    'Units', 'centimeters', ...
    'PaperUnits', 'centimeters', ...
    'Position', [0 0 17.6 4.8], ...
    'PaperPosition', [0 0 17.6 4.8]);

  if mode34
    set(gcf, 'Position', [0 0 17.6 2*4.8], 'PaperPosition', [0 0 17.6 2*4.8]);
    end

  % Save figure to output file
  if save_result
    if experiment == 1
      if mode34
        outputFile = fullfile(global_config.figure_directory_p3, 'paper3_figure2.eps');
      else
        outputFile = fullfile(global_config.figure_directory_p3, 'paper3_figure2b.eps');
      end
    else
      if mode34
        outputFile = fullfile(global_config.figure_directory_p4, 'paper4_figure2.eps');
      else
        outputFile = fullfile(global_config.figure_directory_p4, 'paper4_figure2b.eps');
      end
    end
    export_fig('-transparent', '-nocrop', '-eps', outputFile);
  end
  
  
  
  function bar_panel(handle_axes, subset)
    lin = @(x) x(:);
    avg_location = 9.25;
    
    cla(handle_axes);
    hold(handle_axes, 'on');

    % Draw line at 10cm reference
    handle_ref_line = line([0 10], [0.1 0.1]);
    
    
    % Compute avg +/- SE bar
    muavg = mean(mu(subset, :), 2);
    seavg = std(mu(subset, :), [], 2) / sqrt(8);
        
    handle_bar = bar([1:8 avg_location], [mu(subset, :) muavg]', 1, 'Grouped');
    handle_bars = get(handle_bar, 'Children');

    for i = 1:numel(handle_bars)
      handle_current = handle_bars{i};      
      bar_coords = get(handle_current, 'XData');

      bar_x = mean(bar_coords(:, end));
      
      handle_bar_error{i} = [ ...
        line([bar_x bar_x], muavg(i) + [0 seavg(i)]);
        line(bar_x + [-0.08 0.08], [1 1] * muavg(i) + seavg(i))];
    end
    
    % Add start to mark significant difference
    hyp = ttest(mu(subset(1), :), mu(subset(2), :));
    
    if hyp
      handle_sign_star = text(9, 0.17, '*');
    end

    xlabel(handle_axes, 'Participant', 'FontSize', 12);
    ylabel(handle_axes, 'PSE (cm)', 'FontSize', 12);
    
    % Styling
    set(handle_axes, ...
      'FontSize', 10, ...
      'XTick', [1 2 3 4 5 6 7 8 avg_location], ...
      'YTick', [0 0.10 0.20], ...
      'XTickLabel', {1, 2, 3, 4, 5, 6, 7, 8, 'Avg'}, ...
      'YTickLabel', {'0', '10', '20'});   

    set(handle_bar, 'FaceColor', [0 0 0], 'HandleVisibility', 'off');
    
    for i = 1:numel(handle_bars)
      handle_current = handle_bars{i};      
      color = colors(subset(i), :);      
      set(handle_current, 'FaceColor', color);
      set(handle_bar_error{i}, 'color', color, 'HandleVisibility', 'off');
    end
    
    xlim([0.5 avg_location + 0.5]);
    ylim([0 0.21]);
    
    set(handle_ref_line, 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'HandleVisibility', 'off');
    
    if hyp
      set(handle_sign_star, 'FontSize', 13);
    end
  end

end
