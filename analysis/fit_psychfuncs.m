function [stim_resp, fit, mu, sigma] = fit_psychfuncs(experiment)
  %
  % Fits psychometric functions for either experiment 3 or 4.
  %
    
  [conditions, participants] = get_experiment_info(experiment);  

  
  % %%%%%%%%%%%%%%%%%%%%%%
  % Pre-allocate matrices

  % Number of conditions and participants
  nconditions = size(conditions, 1);
  nparticipants = numel(participants);  
  
  % Stimulus/response arrays per condition and participant
  stim_resp = cell(nconditions, nparticipants);
  fit = cell(nconditions, nparticipants);
  
  % Mu/sigma arrays per condition and participant
  mu = zeros(nconditions, nparticipants);
  sigma = zeros(nconditions, nparticipants);
  
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Fit curves for every participant, condition pair
  
  for s = participants
    sindex = mod(s, 10);
    figure(s);

    data = load_data(s);    
    ntrials = length(data);
    
    for c = 1:nconditions      
      % Filter trials on condition
      subset = filter_trials(data, conditions{c});

      if numel(subset) == 0
        error('No trials in condition...');
      end
      
      % Create stimulus-response matrix
      stim_resp{c, sindex} = build_stim_resp(subset);

      % Make left/right absolute and sort by stimulus intensity
      tmp = stim_resp{c, sindex};
      tmp(:, 1) = abs(tmp(:, 1));
      tmp = sortrows(tmp, 1);

      % Remove outliers
      stim_resp{c,sindex} = magic_table(tmp, c, s);
      
      % Prepare plot
      subplot(3, 4, c);
      hold on;      
      title(num2str(c));      
      
      % Fit and plot curve
      fit{c, sindex} = pfit_wrapper(stim_resp{c, sindex}, 1);      

      % Plot smoothened responses
      [x, y] = smooth_response(stim_resp{c, sindex});
      plot(x, y, 'r.-');      
      
      % Store mu and sigma
      mu(c, sindex) = fit{c, sindex}.params.est(1);
      sigma(c, sindex) = fit{c, sindex}.params.est(2);
    end
  end
end


% %%%%%%%%%%
% Functions


%
% Load cleaned data for a single participant
%
function data = load_data(s)
  global global_config;
  
  data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));
  data = data.data;
end


%
% Returns conditions and participants for the given experiment.
%
function [conditions, participants] = get_experiment_info(experiment)
  global global_config;
  
  % Load conditions and participant numbers for
  % specified experiment
  if experiment == 1 || experiment == 3
    conditions = global_config.conditions_p3;
    participants = 1:8;
  elseif experiment == 2 || experiment == 4
    conditions = global_config.conditions_p4;
    participants = 11:18;
  else
    error('Invalid experiment specified.');
  end  
end


%
% Fit single psychometric function.
%
function result = pfit_wrapper(stim_resp, plot)
  if plot
    plot = 'plot without stats';
  else
    plot = 'no plot';
  end
  
  [null, result] = pfit(stim_resp, ...
    plot, 'runs', 4999, 'sens', 0, ...
    'shape', 'cumulative gaussian', ...
    'n_intervals', 1, ...
    'lambda_equals_gamma', 1);  
end


%
% Returns only those trials that belong to the specified
% condition.
%
function [subset, selection] = filter_trials(data, condition)  
  % Create selection matrix, containing true
  % if the trial should be picked
  ntrials = length(data);
	selection = false(ntrials, 1);
  
  for cs = 1:size(condition, 1)
    selection = selection | ...
      arrayfun(@(t) ...
        t.fix_type{1}(1) == condition{cs, 1}(1) & ...
        t.fix_type{2}(1) == condition{cs, 3}(1) & ...
        all(t.fix_distance == [condition{cs, [2 4]}]) & ...
        t.reference == condition{cs, 5} ...
      , data)';
  end

  % Then create subset of data with only
  % trials from this condition
  subset = data(selection);  
end


%
% Builds the stimulus-response array required
% for psignifit.
%
function stim_resp = build_stim_resp(subset)
  mixer = [0 1; 1 0];  
  
  stim = arrayfun(@(t) t.sled_distance(3 - t.reference), subset)';
  
  % Becase responses need to be inverted when the
  % reference is was presented in the second interval,
  % some non-trivial code is required.
	resp = arrayfun(@(t) mixer(t.reference, 1 + t.response), subset)';

  % Build array, the last column represents the number of repetitions
  stim_resp = [stim, resp, ones(length(subset), 1)];
end
