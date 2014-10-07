function output_p3 = run_model(model)
    % Runs the model
    
    global global_config;
    
    % Parameters
    n_bootstrap_runs = 1; %3999;
    n_participants = 8;
    
    
    % Load all data
    source_p3 = load('../analysis/psychometrics_p3.mat');
    source_p4 = load('../analysis/psychometrics_p4.mat');
    
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Prepare output structures
    
    % Create output structures
    output_p3 = struct([]);
    output_p4 = struct([]);
    
    % Load original data into output structures
    for sb = 1:n_participants
        data_p3 = filter_data(source_p3, sb);
        data_p4 = filter_data(source_p4, sb);
        
        data = combine_data(data_p3, data_p4);
        
        fields = {'m1', 'm2', 'mr', 'mp', 'e1', 'e2', 'er', 'ep'};
        for fl = 1:numel(fields)
            output_p3(sb).data.(fields{fl}) = data_p3.(fields{fl});
            output_p4(sb).data.(fields{fl}) = data_p4.(fields{fl});
        end
        
        output_p3(sb).fit = model.solve_params(data);
        
        % Predictions for experiment 3 and 4
        output_p3(sb).pred.mp = model.predict_mu_probe(output_p3(sb).fit, data_p3);
        output_p3(sb).pred.m2 = model.predict_mu_second(output_p3(sb).fit, data_p3);
        
        output_p4(sb).pred.mp = model.predict_mu_probe(output_p3(sb).fit, data_p4);
        output_p4(sb).pred.m2 = model.predict_mu_second(output_p3(sb).fit, data_p4);
        
        % Perform bootstrap
        output_p3(sb).pred_sim.mp = nan(n_bootstrap_runs, 12);
        output_p3(sb).pred_sim.m2 = nan(n_bootstrap_runs, 12);
        
        output_p4(sb).pred_sim.mp = nan(n_bootstrap_runs, 8);
        output_p4(sb).pred_sim.m2 = nan(n_bootstrap_runs, 8);
        
        for r = 1:n_bootstrap_runs
            data_p3 = filter_data(source_p3, sb, r);
            data_p4 = filter_data(source_p4, sb, r);
            
            data = combine_data(data_p3, data_p4);
            
            output_p3(sb).sim(r, :) = model.solve_params(data);
            
            output_p3(sb).pred_sim.mp(r, :) = model.predict_mu_probe(output_p3(sb).sim(r, :), data_p3);
            output_p3(sb).pred_sim.m2(r, :) = model.predict_mu_second(output_p3(sb).sim(r, :), data_p3);
            
            output_p4(sb).pred_sim.mp(r, :) = model.predict_mu_probe(output_p3(sb).sim(r, :), data_p4);
            output_p4(sb).pred_sim.m2(r, :) = model.predict_mu_second(output_p3(sb).sim(r, :), data_p4);
        end
        
        fprintf('%d:', sb);
        
        sim = nanmedian(output_p3(sb).sim, 1);
        %fprintf(' %.2f', sim);
        fprintf(' %s', strtrim(sprintf(' %.2f', output_p3(sb).fit)));
        
        % Compute performance statistics for fit
        pred(sb, :) = [output_p3(sb).pred.mp output_p4(sb).pred.mp];
        act(sb, :) = [output_p3(sb).data.mp output_p4(sb).data.mp];
        
        sse = sum((pred(sb, :) - act(sb, :)) .^ 2);
        rsq = r_squared(act(sb, :), pred(sb, :));

        fprintf(' sse %.2f rsq %.2f\n', sse, rsq);
        
        % SSE -> sum(error .^ 2);
        % RSQ -> r_squared(actual, predicted)
        %         L = probablity of (data given model, parameter)
        %         k = number of free parameters
        % BIC -> -2 * ln(L) + k * (ln(n) - ln(2*pi));
    end
        
    sse = sum((pred(:) - act(:)) .^ 2);
    rsq = r_squared(act(:), pred(:));
    
    fprintf('All: sse %.2f rsq %.2f\n', sse, rsq);
    
    save(sprintf('model_%s.mat', model.get_name()), 'output_p3', 'output_p4');
    
    
    %
    % Change the structure of the data to make it easier to use it in the model.
    %
    % If the i_run argument is present, resampled data that
    % can be used for a bootstrap analysis is returned. Otherwise, the
    % original data matrix is returned (i.e. not resampled).
    %
    % Conditions: small caps are probe intervals
    %
    % N: Bw wB  Wb bW
    % N: Fw wF  Wf fW
    % N: Bf fB  Fb bF
    %
    % B: Nf fN  Fn nF
    % F: Nf fN  Fn nF
    %
    function data = filter_data(source, i_part, i_run)
        data = [];
        
        % Copy required data
        if nargin < 3
            mu = source.mu(:, i_part)';
        else
            mu = cellfun(@(x) x.params.sim(i_run, 1), source.fit);
            mu = mu(:, i_part)';
            
        end
        
        %eye_gain_extended = source.eye_gain_extended_0_5;
        eye_gain_extended = source.eye_gain_extended;
        
        n_conds = size(source.mu, 1);
        
        % Restructure psychometrics (mu)
        data.mr = ones(size(mu)) * 0.1;
        data.mp = mu;
        
        data.m1(1:2:n_conds) = data.mr(1:2:n_conds);
        data.m1(2:2:n_conds) = data.mp(2:2:n_conds);
        
        data.m2(1:2:n_conds) = data.mp(1:2:n_conds);
        data.m2(2:2:n_conds) = data.mr(2:2:n_conds);
        
        % Restructure eye movement data
        if n_conds == 12
            mmtx = [1, 2, 2, 1, 3, 4, 4, 3, 5, 6, 6, 5];
        else
            mmtx = [1, 2, 2, 1, 3, 4, 4, 3];
        end
        
        % Fixation depth
        depth = eye_gain_extended.depth(:, :, 1);
        data.d1 = depth(:, mmtx);
        depth = eye_gain_extended.depth(:, :, 2);
        data.d2 = depth(:, mmtx);
        
        data.dr(1:2:n_conds) = data.d1(1:2:n_conds);
        data.dr(2:2:n_conds) = data.d2(2:2:n_conds);
        
        data.dp(1:2:n_conds) = data.d2(1:2:n_conds);
        data.dp(2:2:n_conds) = data.d1(2:2:n_conds);
        
        % Eye movement gain
        eye = squeeze(eye_gain_extended.gain(:, :, 1));
        data.e1 = eye(i_part, mmtx);
        
        eye = squeeze(eye_gain_extended.gain(:, :, 2));
        data.e2 = eye(i_part, mmtx);
        
        data.er(1:2:n_conds) = data.e1(1:2:n_conds);
        data.er(2:2:n_conds) = data.e2(2:2:n_conds);
        
        data.ep(1:2:n_conds) = data.e2(1:2:n_conds);
        data.ep(2:2:n_conds) = data.e1(2:2:n_conds);
    end
end

function data = combine_data(data1, data2)
    data = struct();
    fields = fieldnames(data1);
    
    for i = 1:numel(fields)
        data.(fields{i}) = [data1.(fields{i}), data2.(fields{i})];
    end    
end

