function perform_analyses()
%
% This script calls the other analysis functions and stores the result
% in the psychometrics_p#.mat file with # indicating experiment 3 or 4.
%
  
  global global_config;
  
  outputfiles = {'psychometrics_p3.mat', 'psychometrics_p4.mat'};
  
  for experiment = 1:2
    fprintf('Running analyses for experiment %d\n', experiment);
    outputfile = outputfiles{experiment};
    
    fprintf(' Fitting psychometric functions\n');
    [stim_resp, fit, mu, sigma, collapsed] = fit_psychfuncs(experiment);
    
    fprintf(' Extended (gain / exp)\n');
    eye_gain = collect_eye_gain(experiment);
    
    save(fullfile(global_config.cache_directory ,outputfiles{experiment}), 'stim_resp', 'fit', 'mu', 'sigma', 'eye_gain');
  end
end
