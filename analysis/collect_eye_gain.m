function out = collect_eye_gain(mode, experiment, participants)
%
% If mode is simple ...
%
% If mode is simple_only_1st ...
%
% If mode is extended_DIST (e.g. extended_2.0) then the specified
% distance will be used as a reference (i.e. gain will be comuputed
% relative to eye movements made to fixations at that distance).
% Otherwise (i.e. when extended is used without specifying a distance),
% the actual fixation distance is used.
%
        
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

    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % Mode: simple_*
    
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
        
    % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    % Mode: extended_*
        
    elseif strncmp(mode, 'extended', 8)
        if strcmp(mode, 'extended')
            distance = NaN;
            fprintf(' => Using actual distance\n');
        else
            distance = str2double(mode(10:end));
            fprintf(' => Using distance: %.2fm\n', distance);
        end
        
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
                    [mn, bint] = regress(Y(:, i_int), X(:, i_int));
                    
                    if isnan(distance)
                        out.depth(1, i_cond, i_int) = condition{i_int * 2};
                    else
                        out.depth(1, i_cond, i_int) = distance;
                    end
                    
                    out.gain(s, i_cond, i_int) = mn;
                    out.low(s, i_cond, i_int) = abs(bint(1) - mn);
                    out.high(s, i_cond, i_int) = abs(bint(2) - mn);
                    
                    mn_boot = bootstrp(4999, @regress, X(:, i_int), Y(:, i_int));
                    out.gain_boot{s, i_cond, i_int} = mn_boot;
                end
            end
        end
    else
        error(['Mode not supported: ' mode]);
    end
end

