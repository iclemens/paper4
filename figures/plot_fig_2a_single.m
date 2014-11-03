function plot_fig_2a_single(experiment, mode34)
  global global_config;
  
  % Settings  
  participant = 7;
  colors = color_scheme(experiment);

  
  % Load data
  if experiment == 1
    tmp = load(fullfile(global_config.cache_directory, 'psychometrics_p3.mat'));
    stim_resp = tmp.stim_resp;
    fit = tmp.fit;
  else
    tmp = load(fullfile(global_config.cache_directory, 'psychometrics_p4.mat'));
    stim_resp = tmp.stim_resp;
    fit = tmp.fit;
  end 
  
  % Create plots
  figure(3);
  clf;  
  
  if mode34
    rows = 2;
  else
    rows = 1;
  end
  
  if experiment == 1
    curve_panel(subplot(rows, 3, 1), 1:2);
    curve_panel(subplot(rows, 3, 2), 3:4);
    curve_panel(subplot(rows, 3, 3), 5:6);
  
    subplot(rows, 3, 2); ylabel(' ');
    subplot(rows, 3, 3); ylabel(' ');  
  else
    curve_panel(subplot(rows, 2, 1), 1:2);
    curve_panel(subplot(rows, 2, 2), 3:4);
  
    subplot(rows, 2, 2); ylabel(' ');
  end

  % Set figure style
  set(gcf, ...
    'PaperUnits', 'Centimeters', ...
    'PaperOrientation', 'Portrait', ...
    'Units', 'Centimeters');
    
  set(gcf, ...
    'PaperPosition', [0 0 17.6 4.8], ...  
    'Position', [0 0 17.6 4.8]);
  
  if ~mode34
    if experiment == 1
      export_fig('-transparent', '-nocrop', '-eps', fullfile(global_config.figure_directory_p3, 'paper3_figure2a.eps'));
    else
      export_fig('-transparent', '-nocrop', '-eps', fullfile(global_config.figure_directory_p4, 'paper4_figure2a.eps'));
    end
  end

  function curve_panel(handle_axes, subset)
    cla(handle_axes);
    hold(handle_axes, 'on');
    
    handle_perfect_pse = line([0.1 0.1], [0 1]);
    handle_guess_line = line([0 0.4], [0.5 0.5]);
    
    plot_raw_curves(subset);
    plot_binned_responses(subset);
    plot_collapsed_curves(subset);
    
    xlabel('Probe stimulus (cm)', 'FontSize', 12);
    ylabel('P[Resp = Longer]', 'FontSize', 12);
    
    % Panel style
    ylim([0 1]); 
    xlim([0 0.30]);

    set(gca, ...
      'FontSize', 10, ...
      'YTick', [0 0.25 0.5 0.75 1], ...
      'XTick', [0 0.10 0.20 0.30], ...
      'XTickLabel', {'0', '10', '20', '30'}, ...
      'YTickLabel', {'0', '0.25', '0.50', '0.75', '1'});
    
    for handle = [handle_perfect_pse, handle_guess_line]
      set(handle, ...
        'Color', [0.5 0.5 0.5], ...
        'LineStyle', '--', ...
        'HandleVisibility', 'off');
    end
  end
  
  function plot_raw_curves(subset)
    for i = 1:numel(subset)
      i_conditions = subset(i) * 2 - [1 0];
      
      for i_condition = i_conditions
        params = fit{i_condition, participant}.params.est;        
        handle_curve = plot_curve(params);

        set(handle_curve, ...
          'Color', [0.7 0.7 0.7], ...
          'LineWidth', 1, ...
          'HandleVisibility', 'off');        
      end
    end
  end

  
  function plot_binned_responses(subset)
    xbin = 0:0.02:0.2;

    for i = 1:numel(subset)
      i_conditions = subset(i) * 2 - [1 0];
      color = (colors(subset(i), :));
      
      [pright_1, nsamples_1] = bin_responses(xbin, stim_resp{i_conditions(1), participant});
      [pright_2, nsamples_2] = bin_responses(xbin, stim_resp{i_conditions(2), participant});
      
      nsamples = nsamples_1 + nsamples_2;
      pright = (nsamples_1 .* pright_1 + nsamples_2 .* pright_2) ./ nsamples;
      
      for ix = 1:length(xbin)
        if nsamples(ix) == 0, continue; end
        
        handle = plot(xbin(ix), pright(ix), 'o', 'MarkerSize', 1 + 3 * log(1 + nsamples(ix)));
        
        set(handle, ...
          'MarkerFaceColor', color, ...
          'MarkerEdgeColor', color * 3.5 / 4, ...
          'HandleVisibility', 'Off');
      end
    end  
  end

  function plot_collapsed_curves(subset)
    for i = 1:numel(subset)
      i_conditions = subset(i) * 2 - [1 0];
      color = colors(subset(i), :);
            
      fit_1 = fit{i_conditions(1), participant};
      fit_2 = fit{i_conditions(2), participant};
      params = 0.5 * (fit_1.params.est + fit_2.params.est);

      fprintf('Plotting collapsed curve\n');
      fprintf('%.4f %.4f\n', diff(fit_1.params.lims([1 4], 1)), diff(fit_2.params.lims([1 4], 1)));
      
      
      handle = plot_curve(params);    

      set(handle, 'Color', color, 'LineWidth', 2);
    end
  end
  
  
  function handle = plot_curve(params)
    X = linspace(0, 0.4, 1000);
    
    handle = plot(X, params(3) + (1 - sum(params(3:4))) * ...
      psychf('cumulative Gaussian', params(1:2), X));
  end
  

  function color = soft(color)
    color = mean([1 1 1; 1 1 1; color]);
  end

  
  function [pright, nsamples] = bin_responses(xbin, sr)
    width = 0.5 * (xbin(2) - xbin(1));
    
    pright = nan(size(xbin));
    nsamples = nan(size(xbin));
    
    for ix = 1:length(xbin)
      x = xbin(ix);
      selection = sr(:, 1) >= (x - width) & sr(:, 1) <= (x + width);
      pright(ix) = mean(sr(selection, 2));
      nsamples(ix) = sum(selection);
    end
  end  
end
