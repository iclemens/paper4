function output_p3 = run_model(model)
    % Runs the model
            
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
    
    for sb = 1:n_participants
        output_p3(sb).pred_sim.mp = nan(n_bootstrap_runs, 12);
        output_p3(sb).pred_sim.m2 = nan(n_bootstrap_runs, 12);
        
        output_p4(sb).pred_sim.mp = nan(n_bootstrap_runs, 8);
        output_p4(sb).pred_sim.m2 = nan(n_bootstrap_runs, 8);
    end
    
    
    % %%%%%%%%%%%
    %  Fit model
        
    for sb = 1:n_participants
        % Load original data into output structures
        data_p3 = filter_data(source_p3, sb);
        data_p4 = filter_data(source_p4, sb);
        
        data_p3 = average_order_effect(data_p3);
        data_p4 = average_order_effect(data_p4);
        
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
        
        eye_gain_extended = source.eye_gain_extended;
                
        % Restructure psychometrics (mu)
        data.mr = ones(size(mu)) * 0.1;
        data.mp = mu;
        
        % Fixation depth
        data.d1 = expand_conditions(eye_gain_extended.depth(:, :, 1));
        data.d2 = expand_conditions(eye_gain_extended.depth(:, :, 2));
                
        % Eye movement gain
        data.e1 = expand_conditions(eye_gain_extended.gain(i_part, :, 1));
        data.e2 = expand_conditions(eye_gain_extended.gain(i_part, :, 2));

        % Convert intervals to reference/probe and vice versa
        [data.m1, data.m2] = weave(data.mr, data.mp);        
        [data.dr, data.dp] = weave(data.d1, data.d2);
        [data.er, data.ep] = weave(data.e1, data.e2);        
    end
end


%
% Converts first/second interval format data
% into reference/probe format. 
%
% This function requires that all even rows
% are reference first and all odd rows are
% reference second.
%
function [r, p] = weave(one, two)
  n_conds = numel(one);
  
  r(1:2:n_conds) = one(1:2:n_conds);
  r(2:2:n_conds) = two(2:2:n_conds);
  
  p(1:2:n_conds) = two(1:2:n_conds);
  p(2:2:n_conds) = one(1:2:n_conds);
end


%
% Expands Ab Ba into Ab bA Ba aB in order to match
% all of the 12 or 8 trial conditions (experiment 3
% and 4 respectively).
%
function data = expand_conditions(data)
  M = [1 2 2 1];
  n = size(data, 2) / 2;
  
  seq = ceil((1:(n*4))/4 - 1) * 2 + repmat(M, 1, n);
  
  data = data(:, seq, :);
end


%
% Combines two data from two experiments
%
function data = combine_data(data1, data2)
    data = struct();
    fields = fieldnames(data1);
    
    for i = 1:numel(fields)
        data.(fields{i}) = [data1.(fields{i}), data2.(fields{i})];
    end    
end


%
% Averages out order effect
% Requires order of conditions to be Ab bA
% The output will only consist of Ab
% Interval order will be removed
%
function data = average_order_effect(data)
  fields = fieldnames(data);
  
  for i = 1:numel(fields)
    % Remove first/second interval fields as averaging across 
    % reference order makes them obsolote.
    if ctype_isdigit(fields{i}(end))
      data = rmfield(data, fields{i});
      continue;
    end
    
    % Average other fields accross reference order
    data.(fields{i}) = ...
      0.5 * data.(fields{i})(1:2:end, :) + 0.5 * data.(fields{i})(2:2:end, :);
  end
  
  end


%
% Returns true if character c is a digit
%
function v = ctype_isdigit(c)
  v = (c >= '0') && (c <= '9');
end