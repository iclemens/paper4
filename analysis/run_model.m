function output_p3 = run_model(model)
    % Runs the model

    participants = 1:8;
    
    % Parameters
    n_bootstrap_runs = 1; %3999;
    n_participants = numel(participants);

    % Load all data
    source_p3 = load('../analysis/psychometrics_p3.mat');
    source_p4 = load('../analysis/psychometrics_p4.mat');
    
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Prepare output structures
    
    % Create output structures
    output_p3 = struct([]);
    output_p4 = struct([]);
    
    for sb = 1:n_participants
        output_p3(sb).pred_sim.mp = nan(n_bootstrap_runs, 12);
        output_p3(sb).pred_sim.m2 = nan(n_bootstrap_runs, 12);
        
        output_p4(sb).pred_sim.mp = nan(n_bootstrap_runs, 8);
        output_p4(sb).pred_sim.m2 = nan(n_bootstrap_runs, 8);
    end
    
    
    Rsq = zeros(1, n_participants);
    BIC = zeros(1, n_participants);
    
    
    % %%%%%%%%%%%
    %  Fit model
        
    for sb = 1:n_participants
        % Combined data from both datasets and
        %  (optionally) average out order effect
        
        data_p3 = filter_data(source_p3, sb);
        data_p4 = filter_data(source_p4, sb);
        
        data_p3 = average_order_effect(data_p3);
        data_p4 = average_order_effect(data_p4);
        
        data = combine_data(data_p3, data_p4);

        % Load original data into output structures
        fields = {'mr', 'mp', 'er', 'ep'};

        for fl = 1:numel(fields)
            output_p3(sb).data.(fields{fl}) = data_p3.(fields{fl});
            output_p4(sb).data.(fields{fl}) = data_p4.(fields{fl});
        end
                        
        output_p3(sb).fit = model.solve_params(data);
        params(sb, :) = output_p3(sb).fit;
        
        % Predictions for experiment 3 and 4
        output_p3(sb).pred.mp = model.predict_mu_probe(output_p3(sb).fit, data_p3);        
        output_p4(sb).pred.mp = model.predict_mu_probe(output_p3(sb).fit, data_p4);
        
        
        Lp3 = compute_likelihood(source_p3, sb, output_p3(sb).pred.mp);
        Lp4 = compute_likelihood(source_p4, sb, output_p4(sb).pred.mp);               
        LL = Lp3 + Lp4;       
        
        % Perform bootstrap        
        for r = 1:n_bootstrap_runs
            data_p3 = filter_data(source_p3, sb, r);
            data_p4 = filter_data(source_p4, sb, r);
            
            data = combine_data(data_p3, data_p4);
            
            output_p3(sb).sim(r, :) = model.solve_params(data);
            
            output_p3(sb).pred_sim.mp(r, :) = model.predict_mu_probe(output_p3(sb).sim(r, :), data_p3);
            output_p4(sb).pred_sim.mp(r, :) = model.predict_mu_probe(output_p3(sb).sim(r, :), data_p4);
        end
                        
        % Compute R Squared
        pred(sb, :) = [output_p3(sb).pred.mp output_p4(sb).pred.mp];
        act(sb, :) = [output_p3(sb).data.mp output_p4(sb).data.mp];
        
        Rsq(sb) = max(0, r_squared(act(sb, :), pred(sb, :)));
        
        Rsq(sb) = max(0, r_squared(act(sb, 1:6), pred(sb, 1:6)));
        
        % Compute BIC
        Nobs3 = sum(cellfun(@(entry) size(entry, 1), source_p3.stim_resp), 1);
        Nobs4 = sum(cellfun(@(entry) size(entry, 1), source_p4.stim_resp), 1);
                
        k = numel(output_p3(sb).fit);   % Number of free parameters        
        n = Nobs3(sb) + Nobs4(sb);      % Number of observations / data points
        
        Penalty(sb) = k * (log(n) - log(2 * pi));
        BIC(sb) = -2 * LL + Penalty(sb);
    end

    labels = model.get_param_names();
    
    save(sprintf('data/MDL_%s.mat', model.get_name()), 'output_p3', 'output_p4', 'labels');
    save(sprintf('data/BIC_%s.mat', model.get_name()), 'BIC', 'Rsq', 'params', 'labels');
    
    % Print model output
    fprintf('\n');
    fprintf('Model summary: %s\n', model.get_name());
    fprintf('\n');
    
    for sb = 1:n_participants
      fprintf(' %d: ', sb);      
      fprintf('[%s]', strtrim(sprintf(' %.2f', output_p3(sb).fit)));        
      fprintf('\tR2: %.2f', Rsq(sb));
      %fprintf('\tBIC: %6.01f\tR2: %.2f\tPenalty: %5.01f', BIC(sb), Rsq(sb), Penalty(sb));
      fprintf('\n');
    end
    
    fprintf('\n');
    
    
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
        
        eye_gain = source.eye_gain;
                
        % Restructure psychometrics (mu)
        data.mr = ones(size(mu)) * 0.1;
        data.mp = mu;

        % Fixation depth
        data.d1 = eye_gain.depth(1, :, 1);
        data.d2 = eye_gain.depth(1, :, 2);
               
        % Eye movement gain
        data.e1 = eye_gain.gain(i_part, :, 1);
        data.e2 = eye_gain.gain(i_part, :, 2);

        % Convert intervals to reference/probe and vice versa
        [data.m1, data.m2] = weave(data.mr, data.mp);        
        [data.dr, data.dp] = weave(data.d1, data.d2);
        [data.er, data.ep] = weave(data.e1, data.e2);
    end
end


%
% Compute likelihood of data given predicted PSE
%
function L = compute_likelihood(src, i_participant, mp)
  raw_data = src.stim_resp(:, i_participant);
  
  sigma = cellfun(@(entry) entry.params.est(2), src.fit);  
  sigma = sigma(:, i_participant);

  gamma = cellfun(@(entry) entry.params.est(3), src.fit);  
  gamma = gamma(:, i_participant);  
  
  n_conds = numel(sigma);
  
  if numel(mp) < n_conds
    mp = mp(ceil((1:n_conds)/2));
  end

  L = 0;  
  
  % Loop over conditions
  for i = 1:n_conds
    stim = raw_data{i}(:, 1);
    resp = raw_data{i}(:, 2);
    reps = raw_data{i}(:, 3);
    
    p = gamma(i) + (1 - 2 * gamma(i)) * normcdf(stim, mp(i), sigma(i));
    
    L = L + sum(log(binopdf(resp .* reps, reps, p)));
  end
end
