function [actual_vergence_angle, expected_vergence_angle, out2] = collect_depth(experiment, participants)


    % Y: t.vergence(251)                << out 1
    % Z: t.vergence(271)                << out 2

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
    n_conditions = size(conditions, 1);

    intervals = 1:2;
    
    % Preallocate cell arrays
    expected_vergence_angle = cell(8, n_conditions);
    actual_vergence_angle = cell(8, n_conditions);
    out2 = cell(8, n_conditions);
    
    for s = participants
        if experiment == 1
            data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));
        else
            data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, 10 + s));
        end
        
        data = data.data([data.data.reject] == 0);
        
        slopes = zeros(12, n_conditions);
        
        for i_conditions = 1:n_conditions
            X = [];
            Y = [];
            Z = [];
            
            distance = conditions{i_conditions, 2};

            for i_interval = intervals
                selection = arrayfun(@(t) ...
                    strcmp(t.fix_type{i_interval}, conditions{i_conditions, 1}) && ...
                       t.fix_distance(i_interval) == conditions{i_conditions, 2} , data);                               

                X = [X; arrayfun(@(t) atan2(t.sled_distance(i_interval), distance), data(selection))'];
                Y = [Y; arrayfun(@(t) t.vergence(251, i_interval), data(selection))'];
                Z = [Z; arrayfun(@(t) t.vergence(700, i_interval), data(selection))'];
            end
            
            expected_vergence_angle{s, i_conditions} = X;
            actual_vergence_angle{s, i_conditions} = Y;
            out2{s, i_conditions} = Z;
        end
    end
end