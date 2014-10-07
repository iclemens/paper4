function out = collect_normalized_eye_displacement(mode, experiment, participants)  
  global global_config;
  
  if nargin < 3, participants = 1:8; end;  
  if nargin < 2, experiment = 1; end;
  if nargin < 1, mode = 'simple'; end;    
  
  % Create list of conditions
  if experiment == 1
    conditions = global_config.conditions_p3;
  else
    conditions = global_config.conditions_p4;
  end
  
  conditions = vertcat(conditions{:});
  conditions = conditions([conditions{:, 5}] == 1, 1:4);
  nconditions = size(conditions, 1);
  
  if strncmp(mode, 'simple', 6)
    if experiment == 1
      conditions = conditions(1:(size(conditions, 1)/2), 1:2);
    else
      conditions = conditions(:, 1:2);
    end    
    nconditions = size(conditions, 1);
    
    if strcmp(mode, 'simple_only_1st')
      intervals = 1;
    else
      intervals = 1:2;
    end    
    
    for s = participants
      if experiment == 1
        data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));
      else
        data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, 10 + s));
      end
      
      data = data.data([data.data.reject] == 0);
    
      slopes = zeros(12, nconditions);
      
      for i_conditions = 1:nconditions
        X = [];
        Y = [];

        distance = conditions{i_conditions, 2};
        
        for i_interval = intervals
          selection = arrayfun(@(t) ...
            strcmp(t.fix_type{i_interval}, conditions{i_conditions, 1}) && ...
            t.fix_distance(i_interval) == conditions{i_conditions, 2} , data);

          X = [X; arrayfun(@(t) t.sled_distance(i_interval), data(selection))'];
          Y = [Y; arrayfun(@(t) diff(t.angles([251 751], i_interval)), data(selection))'];
        end
                
        [mn, bint] = regress(Y, X);        
        mn_boot = bootstrp(4999, @regress, X, Y);
        
        out.gain(s, i_conditions) = mn * 0.1;
        out.low(s, i_conditions) = abs(bint(1) - mn) * 0.1;
        out.high(s, i_conditions) = abs(bint(2) - mn) * 0.1;
        
        out.gain_boot{s, i_conditions} = mn_boot * 0.1;
      end      
    end
  else
    
    for s = 1:8
      if experiment == 1
        data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));
      else
        data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, 10 + s));
      end
      
      data = data.data([data.data.reject] == 0);
      
      for i_cond = 1:nconditions
        condition = conditions(i_cond, :);
        
        selection = arrayfun(@(t) ...
          strcmp(t.fix_type{1}, condition{1}) & ...
          strcmp(t.fix_type{2}, condition{3}) & ...
          t.fix_distance(1) == condition{2} & ...
          t.fix_distance(2) == condition{4}, ...
          data);
        
        sled_distance = vertcat(data(selection).sled_distance);
        
        X = sled_distance;
        Y = [arrayfun(@(t) diff(t.angles([251 751], 1)), data(selection))', ...
             arrayfun(@(t) diff(t.angles([251 751], 2)), data(selection))'];
        
        for i_int = 1:2
          [mn, bint] = regress(Y(:, i_int), X(:, i_int));
          
          out.gain(s, i_cond, i_int) = mn;
          out.low(s, i_cond, i_int) = abs(bint(1) - mn) * 0.1;
          out.high(s, i_cond, i_int) = abs(bint(2) - mn) * 0.1;
          
          mn_boot = bootstrp(4999, @regress, X(:, i_int), Y(:, i_int));
          out.gain_boot{s, i_cond, i_int} = mn_boot;
        end
      end
    end
  end
end
