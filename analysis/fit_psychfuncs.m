function [stim_resp, fit, mu, sigma] = fit_psychfuncs(experiment)  
  global global_config;
  
  if nargin < 1
    experiment = 1;
  end
  
  if experiment == 1
    conditions = global_config.conditions_p3;
    participants = 1:8;
  else
    conditions = global_config.conditions_p4;
    participants = 11:18;
  end  
  
  nconditions = size(conditions, 1);
  nparticipants = 8;
  
  mix_matrix = [0 1; 1 0];  
  
  % Collections of stimuli/response arrays
  stim_resp = cell(nconditions, nparticipants);  
  fit = cell(nconditions, nparticipants);

  mu = zeros(nconditions, nparticipants);
  sigma = zeros(nconditions, nparticipants);
  
  for s = participants    
    sindex = s - (experiment - 1) * 10;
    
    figure(s);

    data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));    
    data = data.data;
    
    ntrials = length(data);   
    
    for c = 1:nconditions
      subplot(3, 4, c);
            
      selection = false(ntrials, nconditions);
      
      for cs = 1:size(conditions{c}, 1)
        selection(:, c) = selection(:, c) | arrayfun(@(t) ...
          t.fix_type{1}(1) == conditions{c}{cs, 1}(1) & ...
          t.fix_type{2}(1) == conditions{c}{cs, 3}(1) & ...          
          all(t.fix_distance == [conditions{c}{cs, [2 4]}]) & ...
          t.reference == conditions{c}{cs, 5} ...
          , data)';                
      end
      
      if sum(selection(:, c)) == 0
        error('No trials in condition...');        
      end
      
      % Create stimulus-response matrix
      subset = data(selection(:, c));      
      stim_resp{c, sindex} = [arrayfun(@(t) t.sled_distance(3 - t.reference), subset)', ...
                              arrayfun(@(t) mix_matrix(t.reference, 1 + t.response) , subset)', ...
                              ones(length(subset), 1)];
      
      % Fit traditional curves
      tmp = stim_resp{c, sindex};
      tmp(:, 1) = abs(tmp(:, 1));
      tmp = sortrows(tmp, 1);          

      stim_resp{c,sindex} = magic_table(tmp, c, s);
      
      [~, fit{c, sindex}] = pfit(stim_resp{c, sindex}, ...
        'plot without stats', ... %'no plot', ...
        'runs', 4999, 'sens', 0, ...
        'shape', 'cumulative gaussian', ...
        'n_intervals', 1, ...
        'lambda_equals_gamma', 1);
            
      hold on;
      
      [x, y] = smooth_response(stim_resp{c, sindex});
      plot(x, y, 'r.-');
      
      title(num2str(c));
      
      mu(c, sindex) = fit{c, sindex}.params.est(1);
      sigma(c, sindex) = fit{c, sindex}.params.est(2);      
    end
  end
    
