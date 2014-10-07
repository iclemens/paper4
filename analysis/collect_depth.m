function [out1, out2, dist] = collect_depth(experiment, participants)
    
    global global_config;
    
    if nargin < 2, participants = 1:8; end;
    if nargin < 1, experiment = 1; end;
    
    % Create list of conditions
    if experiment == 1
        conditions = global_config.conditions_p3;
    else
        conditions = global_config.conditions_p4;
    end
    
    conditions = vertcat(conditions{:});
    conditions = conditions([conditions{:, 5}] == 1, 1:4);
    nconditions = size(conditions, 1);
    
    
    
    if experiment == 1
        conditions = conditions(1:(size(conditions, 1)/2), 1:2);
    else
        conditions = conditions(:, 1:2);
    end
    nconditions = size(conditions, 1);

    intervals = 1:2;
    
    
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
            Z = [];
            
            distance = conditions{i_conditions, 2};

            for i_interval = intervals
                selection = arrayfun(@(t) ...
                    strcmp(t.fix_type{i_interval}, conditions{i_conditions, 1}) && ...
                       t.fix_distance(i_interval) == conditions{i_conditions, 2} , data);                               

                sum(selection)
                   
                X = [X; arrayfun(@(t) atan2(t.sled_distance(i_interval), distance), data(selection))'];
                Y = [Y; arrayfun(@(t) t.vergence(251, i_interval), data(selection))'];
                Z = [Z; arrayfun(@(t) t.vergence(271, i_interval), data(selection))'];
            end
            
            dist{s, i_conditions} = X;
            out1{s, i_conditions} = Y;
            out2{s, i_conditions} = Z;
        end
    end
end