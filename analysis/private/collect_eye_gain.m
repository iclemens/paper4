function [out, conds] = collect_eye_gain(experiment)
%
% Computes eye movement "gain".
%
% Returns a 3D matrix (out.gain) with dimensions:
%  1. Participants
%  2. Conditions
%  3. Interval
%
% The order of conditions (2nd dimension) is:
%  body-world, world-body, none-world, world-none, body-none, none-body
% for the first experiment.
%
% Bootstraps (out.gain_boot) and confidence intervals (out.low and
% out.high) are also computed.
%

  global global_config;
  
  conds = cell(1, 6, 2);
  
  if nargin < 3, participants = 1:8; end;
  if nargin < 2, experiment = 1; end;
  
  % Create list of conditions
  if experiment == 1
    conditions = global_config.conditions_p3;
  else
    conditions = global_config.conditions_p4;
  end
  
  conditions = vertcat(conditions{:});
  nconditions = size(conditions, 1);
  
  distance = NaN;
  
  for s = 1:8
    figure(s);
    
    if experiment == 1
      data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));
    else
      data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, 10 + s));
    end
    
    data = data.data([data.data.reject] == 0);
    
    % Loop over reference first movements
    for i_cond = 1:nconditions
      condition = conditions(i_cond, :);
      
      % Select trials that match this condition
      selection = arrayfun(@(t) ...
        strcmp(t.fix_type{1}, condition{1}) & ...
        strcmp(t.fix_type{2}, condition{3}) & ...
        t.fix_distance(1) == condition{2} & ...
        t.fix_distance(2) == condition{4}, ...
        data);
      
      sled_distance = vertcat(data(selection).sled_distance);
      
      % Expected eye movement angle (for both intervals)
      if isnan(distance)
        X = [atan2(sled_distance(:, 1), condition{2}), ...
          atan2(sled_distance(:, 2), condition{4})];
      else
        X = [atan2(sled_distance(:, 1), distance), ...
          atan2(sled_distance(:, 2), distance)];
      end
      
      % Eye movement angle (for both intervals)
      Y = [arrayfun(@(t) diff(t.angles([251 751], 1)), data(selection))', ...
        arrayfun(@(t) diff(t.angles([251 751], 2)), data(selection))'];
      
      for i_int = 1:2
        subplot(4, 6, i_int*6 + i_cond - 6);
        
        [mn, bint] = regress(Y(:, i_int), X(:, i_int));
        
        if isnan(distance)
          out.depth(1, i_cond, i_int) = condition{i_int * 2};
        else
          out.depth(1, i_cond, i_int) = distance;
        end
        
        conds{1, i_cond, i_int} = [condition{1} '-' condition{3}];
        
        plot(X(:, i_int), Y(:, i_int), 'r.'); lsline;
        title([conds{1, i_cond, i_int} ' ' sprintf('%.2f', mn)]);
        
        out.gain(s, i_cond, i_int) = mn;
        out.low(s, i_cond, i_int) = abs(bint(1) - mn);
        out.high(s, i_cond, i_int) = abs(bint(2) - mn);
        
        mn_boot = bootstrp(4999, @regress, X(:, i_int), Y(:, i_int));
        out.gain_boot{s, i_cond, i_int} = mn_boot;
      end
    end
  end
end
