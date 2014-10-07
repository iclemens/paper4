global global_config;

%%
[depth_begin, depth_end] = collect_depth(2, 1:8);

%%
conditions = global_config.conditions_p4;

conditions = vertcat(conditions{:});
conditions = conditions([conditions{:, 5}] == 1, 1:4);
nconditions = size(conditions, 1);
conditions = conditions(:, 1:2);

for c = 1:4
    D = vertcat(depth_begin{:, c});
    
    D_begin(c) = nanmean(D);
    S_begin(c) = nanstd(D);
    
    D = vertcat(depth_end{:, c});
    
    D_end(c) = nanmean(D);
    S_end(c) = nanstd(D);

end

clf; subplot(2, 1, 1); hold on;
errorbar(D_begin, S_begin);
subplot(2, 1, 2); hold on;
errorbar(D_end, S_end);



D = cellfun(@(x) mean(x), depth_begin)
plot(D')

cellfun(@(x) std(x), depth_begin)


%%

% Steps: remove outliers, then subtract or "normalize" and plot depth

clear('Dt', 'M', 'S');

for s = 1:8
    for c = 1:2
        D = vertcat(depth_end{s, [1 3] + (c - 1)});
        outliers = abs(D - mean(D)) > 2 * std(D);
        D(outliers) = NaN;
        
        Dt{s}(:, c) = D;
        M{s}(:, c) = nanmean(D);
        S{s}(:, c) = nanstd(D);
    end
end

%%

for i = 1:8
    r = any(isnan(Dt{i}), 2);
    
    
    fprintf('Participant %d: %.2f%%\n', i, mean(Dt{i}(~r, 1) > Dt{i}(~r, 2)) * 100);
    %M(:, i) = nanmean(Dt);
end

%errorbar(M, S); shg;

%%

Dt{1, 2} - Dt{1, 1}
Dt{1, 2} - Dt{1, 1}

%%
Ma = mean([M(:, 2); M(:, 4)] - [M(:, 1); M(:, 3)]);
Sa = std([M(:, 2); M(:, 4)] - [M(:, 1); M(:, 3)]);

errorbar(Ma, Sa)

