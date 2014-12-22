function out = collect_eye_gain_per_type(experiment)
%
% Collects eye movement gain by condition (i.e. world/body/near for first
% experiment).
%

    global global_config;
    
	participants = 1:8;

    % Use first and second interval
    intervals = 1:2;

    % Create list of conditions
    if experiment == 1
        conditions = global_config.conditions_p3;
    elseif experiment == 2
        conditions = global_config.conditions_p4;
    else
        error('Invalid condition specified, only 1 and 2 are allowed.');
    end

    % List and count conditions
    conditions = vertcat(conditions{:});
    conditions = conditions([conditions{:, 5}] == 1, 1:4);
    nconditions = size(conditions, 1);
    
    if experiment == 1
        conditions = conditions(1:(size(conditions, 1)/2), 1:2);
    else
        conditions = conditions(:, 1:2);
    end
    nconditions = size(conditions, 1);

    % Collect eye movements
    for s = participants
        if experiment == 1
            data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, s));
        elseif experiment == 2
            data = load(sprintf('%s/cleaned_%02d.mat', global_config.cache_directory, 10 + s));
        else
            error('Invalid condition specified, only 1 and 2 are allowed.');
        end

        % Only use trials that were not rejected previously
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

                X = [X; arrayfun(@(t) atan2(t.sled_distance(i_interval), distance), data(selection))'];
                Y = [Y; arrayfun(@(t) diff(t.angles([251 751], i_interval)), data(selection))'];
            end

            [mn, bint] = regress(Y, X);

            % Return fixation depth
            out.depth(1, i_conditions) = distance;

            % Return gains and confidence interval bounds
            out.gain(s, i_conditions) = mn;
            out.low(s, i_conditions) = abs(bint(1) - mn);
            out.high(s, i_conditions) = abs(bint(2) - mn);

            % Run bootstrap and return bootsrapped gains
            mn_boot = bootstrp(4999, @regress, X, Y);
            out.gain_boot{s, i_conditions} = mn_boot;
        end
    end        
end

