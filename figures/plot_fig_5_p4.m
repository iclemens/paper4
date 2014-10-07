function plot_fig_5_p4()
  global global_config;

  % Parameters from near experiment
  Parameters = [ ...
      0.25, ...
      0.15, ...
      0.25, ...
      0.06, ...
      0.13, ...
      0.24, ...
      0.42, ...
      0.18, ...
  ];

  % Load near-far data
  data4 = load('../analysis/psychometrics_p4.mat');

  % Make predictions based on gain (i.e. taking into account distance)
  [ref_eye, prb_eye] = expand_eye_data(data4, 'gain', 2);  
  ref_eye = ref_eye * atan2(0.1, 0.5);
  prb_eye = prb_eye * atan2(0.1, 0.5);
  
  for i = 1:8
    mu_hat_gain(:, i) = func_ref_probe(Parameters(i), 1:8, i);
  end
  
  % Make predictions based on eye movements only
  [ref_eye, prb_eye] = expand_eye_data(data4, 'disp', 2);    
  for i = 1:8    
    mu_hat_disp(:, i) = func_ref_probe(Parameters(i), 1:8, i);
  end

  % Collapse across reference order
  fsa = @(x) 0.5 * (x(1:2:end, :) + x(2:2:end, :));
  mu = fsa(data4.mu);
  mu_hat_gain = fsa(mu_hat_gain);
  mu_hat_disp = fsa(mu_hat_disp);  

  
  % % % % % % % % % % % %
  % Prepare data to plot %
  % % % % % % % % % % % %
  
  X = lin(mu(3:4, :)) - 0.1;
  Yg = lin(mu_hat_gain(3:4, :)) - 0.1;
  Yd = lin(mu_hat_disp(3:4, :)) - 0.1;
  
  SlopeG = regress(Yg, X);
  SlopeD = regress(Yd, X);
  SlopeDZ = regress(Yd - X, X);

  [RhoG, pG] = corr(X, Yg);
  [RhoD, pD] = corr(X, Yd);
  [RhoDZ, pDZ] = corr(X, Yd - X);

  fprintf('Actual gain: Rho: %.2f; p: %.2f; Slope: %.2f\n', RhoG, pG, SlopeG);
  fprintf('Eye angle:   Rho: %.2f; p: %.2f; Slope: %.2f\n', RhoD, pD, SlopeD);

  fprintf('Eye angle D0:Rho: %.2f; p: %.2f; Slope: %.2f\n', RhoDZ, pDZ, SlopeDZ);

  % % % % % % % % % % % %
  % Create actual figure %
  % % % % % % % % % % % %
  
  clf; hold on;

  % Hypotheses lines
  line([0 0.2], [0 0.2], 'Color', 'k', 'LineStyle', '--');
  line([0 0.2], [0.1 0.1], 'Color', 'k', 'LineStyle', '--');
  
  handle_dp_g = plot(0.1 + X, 0.1 + Yg, 'ro');
  handle_ln_g = plot(0.1 + [-0.1 0.2], 0.1 + SlopeG * [-0.1 0.2]);
  
  handle_dp_d = plot(0.1 + X, 0.1 + Yd, 'bo');
  handle_ln_d = plot(0.1 + [-0.1 0.2], 0.1 + SlopeD * [-0.1 0.2]);
  
  xlabel('Actual PSE (cm)', 'FontSize', 12);
  ylabel('Predicted PSE (cm)', 'FontSize', 12);

  
  % % % % %
  % Style % 
  % % % % %

  color_g = [0 0 1];
  color_d = [1 0 0];  
  
  set(handle_dp_g, ...
    'MarkerFaceColor', 0.4 * [1 1 1] + 0.6 * color_g, ...
    'MarkerEdgeColor', color_g, ...
    'MarkerSize', 3);   
  
  set(handle_dp_d, ...
    'MarkerFaceColor', 0.4 * [1 1 1] + 0.6 * color_d, ...
    'MarkerEdgeColor', color_d, ...
    'MarkerSize', 3);   
  
  set(handle_ln_g, 'Color', color_g);
  set(handle_ln_d, 'Color', color_d);
  
  axis equal;
  xlim([0.05 0.17]);
  ylim([0.05 0.17]);

  set(gca, ...
    'FontSize', 10, ...
    'XTick', [0.05 0.1 0.15 0.2], ...
    'XTickLabel', {'5', '10', '15', '20'}, ...    
    'YTick', [0.05 0.1 0.15 0.2], ...
    'YTickLabel', {'5', '10', '15', '20'});

  set(gcf, ...
    'PaperUnits', 'Centimeters', ...
    'PaperOrientation', 'Portrait', ...
    'Units', 'Centimeters', ...
    'PaperPosition', [0 0 8.5 5], ...
    'Position', [0 0 8.5 5]);  
  
  export_fig('-transparent', '-nocrop', '-eps', sprintf('%s/paper4_figure5.eps', global_config.figure_directory_p4));
  
  function y = lin(x)
    y = x(:);
  end


  function y = sse(x)
    y = sum(x(:) .^ 2);
  end


  function y = func_ref_probe(param, ss, s)
    param(2) = 1 - param(1);
    
    a = (ref_eye(ss, s) * param(1) + param(2)) .* 0.1;
    b = (prb_eye(ss, s) * param(1) + param(2));
    y = a ./ b;
  end

end
