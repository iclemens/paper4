function output = model(mdl, mde, params_p3, flag)
    cfg.model = mdl;
    cfg.mode = mde;
    
    n_params = 1;
    
    if nargin < 4
        flag = 0;
    end
    
    if nargin < 3
        params_p3 = NaN;
    else
        if numel(params_p3) == 1
            params_p3 = ones(8, n_params) * params_p3;
        else
            params_p3 = reshape(params_p3, 8, n_params);
        end
    end
    
    % Load all data
    source_p3 = load('../analysis/psychometrics_p3.mat');
    source_p4 = load('../analysis/psychometrics_p4.mat');
    
    predict_prb = eval(sprintf('@(data, p, c, s) predict_%s_prb(data, p, c, s)', cfg.model));
    predict_mu2 = eval(sprintf('@(data, p, c, s) predict_%s_mu2(data, p, c, s)', cfg.model));
    predict_wgt = eval(sprintf('@(data, p, c, s) predict_%s_wgt(data, p, c, s)', cfg.model));
    
    % Create output structures
    output_p3 = struct([]);
    output_p4 = struct([]);
    
    % Load plain data into structures
    data_p3 = load_data(source_p3);
    data_p4 = load_data(source_p4);
    
    fields = {'mu1', 'mu2', 'mur', 'mup', 'eye_gain1', 'eye_gain2', 'eye_gainr', 'eye_gainp'};
    
    for sb = 1:8
        for fl = 1:numel(fields)
            output_p3(sb).data.(fields{fl}) = data_p3.(fields{fl})(:, sb);
            output_p4(sb).data.(fields{fl}) = data_p4.(fields{fl})(:, sb);
        end
    end
    
    % Fit parameters
    if isnan(params_p3)
        params_p3 = fit_data(data_p3);
    end
    params_p4 = fit_data_p4(data_p4, params_p3);
    
    for sb = 1:8
        output_p3(sb).fit = params_p3(sb, :);
        output_p4(sb).fit = params_p4(sb, :);
    end
    
    
    % Predictions for experiment 3 and 4
    for sb = 1:8
        output_p3(sb).pred.mup = predict_prb(load_data(source_p3), output_p3(sb).fit, 1:12, sb);
        output_p3(sb).pred.mu2 = predict_mu2(load_data(source_p3), output_p3(sb).fit, 1:12, sb);        
        
        if ~flag
            output_p4(sb).pred.mup = predict_prb(load_data(source_p4), output_p3(sb).fit, 1:8, sb);
            output_p4(sb).pred.mu2 = predict_mu2(load_data(source_p4), output_p3(sb).fit, 1:8, sb);
        else
            output_p4(sb).pred.mup = predict_prb(load_data(source_p4), output_p4(sb).fit, 1:8, sb);
            output_p4(sb).pred.mu2 = predict_mu2(load_data(source_p4), output_p4(sb).fit, 1:8, sb);
        end
    end
    
    output = struct();
    output.output_p3 = output_p3;
    output.output_p4 = output_p4;
    
    fprintf('Experiment 3\n');
    dump_output(output_p3);
    fprintf('\nExperiment 4\n');
    dump_output(output_p4);
    
    function params_opt = fit_data(data)
        funcrp = @(p, ss, s) predict_prb(data, p, ss, s);
        func12 = @(p, ss, s) predict_mu2(data, p, ss, s);
        
        % Fit model based on these trials:
        ss_fit = 1:4;
                
        % Perform model fits
        for s = 1:8
            if strcmp(cfg.mode, 'rp')
                [params_opt(s, :), ~, exitflag] = fmincon( ...
                    @(p) 1 - r_squared(data.mup(ss_fit, s), funcrp(p, ss_fit, s)), 0.5 * ones(1, n_params), ...
                    [], [], [], [], 0, 1 ...
                );
            elseif strcmp(cfg.mode, '12')
                [params_opt(s, :), ~, exitflag] = fmincon( ...
                    @(p) 1 - r_squared(data.mu2(ss_fit, s), func12(p, ss_fit, s)), 0.5 * ones(1, n_params), ...
                    [], [], [], [], 0, 1 ...
                );
            else
                error('Invalid mode.');
            end 
            
            if(exitflag <= 0)
                params_opt(s, :) = NaN;
            end
        end
    end
    
    
    function params_opt = fit_data_p4(data, prms)
        funcrp = @(p, ss, s) predict_wgt_prb(data, p, ss, s);
        func12 = @(p, ss, s) predict_wgt_mu2(data, p, ss, s);
        
        % Fit model based on these trials:
        ss_fit = 1:8;

        % Perform model fits
        for s = 1:8
            if strcmp(cfg.mode, 'rp')
                params_opt(s, 1) = prms(s, 1);
                [params_opt(s, 2), ~, exitflag] = fmincon( ...
                    @(p) 1 - r_squared(data.mup(ss_fit, s), funcrp([prms(s, :) p], ss_fit, s)), 0.5 * ones(1, n_params), ...
                    [], [], [], [], 0, 1);
            elseif strcmp(cfg.mode, '12')
                params_opt(s, 1) = prms(s, 1);
                [params_opt(s, 2), ~, exitflag] = fmincon( ...
                    @(p) 1 - r_squared(data.mu2(ss_fit, s), func12([prms(s, :) p], ss_fit, s)), 0.5 * ones(1, n_params), ...
                        [], [], [], [], 0, 1);
            else
                error('Invalid mode.');
            end 
            
            if(exitflag <= 0)
                params_opt(s, :) = NaN;
            end
        end
    end    
    
    % % % % % % % % % % % % %
    % Start of actual model %
    % % % % % % % % % % % % %
    
    % Equation for hfd model
    % e m a + m (1 - a) = E M a + M (1 - a)
    % M = m (e a + (1 - a)) / (E a + (1 - a))
    
    % Equation for eye movement model
    % e? (m / d) a + m (1 - a)
    % M = m ( e / d a + (1 - a)) / (E / D a + (1 - a))
    
    
    function mu2 = predict_emv_mu2(data, p, c, s)
        p(2) = p(1);

        a = p(1) * data.eye_gain1(c, s) ./ data.depth1(c, s) + (1 - p(2));
        b = p(1) * data.eye_gain2(c, s) ./ data.depth2(c, s) + (1 - p(2));
        mu2 = (data.mu1(c, s) .* a) ./ b;
    end
    
    function mu2 = predict_hfd_mu2(data, p, c, s)
        p(2) = p(1);

        a = p(1) * data.eye_gain1(c, s) + (1 - p(2));
        b = p(1) * data.eye_gain2(c, s) + (1 - p(2));
        mu2 = (data.mu1(c, s) .* a) ./ b;
    end
    
    function mu2 = predict_wgt_mu2(data, p, c, s)        
        p1 = (data.depth1(c, s) == 0.5) * p(1) + (data.depth1(c, s) == 2.0) * p(2);
        p2 = (data.depth2(c, s) == 0.5) * p(1) + (data.depth2(c, s) == 2.0) * p(2);        
        
        a = p1 .* data.eye_gain1(c, s) + (1 - p1);
        b = p2 .* data.eye_gain2(c, s) + (1 - p2);
        mu2 = (data.mu1(c, s) .* a) ./ b;        
    end
    
    
    
    function mup = predict_emv_prb(data, p, c, s)
        p(2) = p(1);
        
        a = p(1) * data.eye_gainr(c, s) ./ data.depthr(c, s) + (1 - p(2));
        b = p(1) * data.eye_gainp(c, s) ./ data.depthp(c, s) + (1 - p(2));
        mup = (data.mur(c, s) .* a) ./ b;
    end
    
    function mup = predict_hfd_prb(data, p, c, s)
        p(2) = p(1);
        
        a = p(1) * data.eye_gainr(c, s) + (1 - p(2));
        b = p(1) * data.eye_gainp(c, s) + (1 - p(2));
        mup = (data.mur(c, s) .* a) ./ b;
    end
    
    function mup = predict_wgt_prb(data, p, c, s)
        pr = (data.depthr(c, s) == 0.5) * p(1) + (data.depthr(c, s) == 2.0) * p(2);
        pp = (data.depthp(c, s) == 0.5) * p(1) + (data.depthp(c, s) == 2.0) * p(2);
        
        a = pr .* data.eye_gainr(c, s) + (1 - pr);
        b = pp .* data.eye_gainp(c, s) + (1 - pp);
        mup = (data.mur(c, s) .* a) ./ b;        
    end
end

% % % % % % % % % % % %
% End of actual model %
% % % % % % % % % % % %


%
% Print optimal values to screen
%
function dump_output(out)
    for j = 1:8
        fprintf('%d: %.2f\n', j, out(j).fit);
    end
end


%
% Convenience function that computes the sum of squares.
%
function y = ssq(x)
    y = sum(x .^ 2);
end


function y = prob(x)
    prs = normpdf(x, 0, 0.1);
    y = sum(log(1e-10 + (1 - 2e-10) * prs));
end


%
% Convert the multidimensional input x into one-dimensional output.
%
% This function exists because function calls and array indexing
% cannot be chained (e.g. prob(y)(:)). Using this function, we can
% use: lin(prob(y)) instead.
%
function y = lin(x)
    y = x(:);
end


%
% Change the structure of the data to make it easier to use it in the model.
%
% model. If the index input argument is present, resampled data that
% can be used for a bootstrap analysis is returned. Otherwise, the
% complete data matrix is returned (i.e. not resampled).
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
function data = load_data(source, index)
    data = [];
    
    % Copy required data
    if nargin < 2
        mu = source.mu;
    else
        mu = cellfun(@(x) x.params.sim(index, 1), source.fit);
    end
    
    %eye_gain_extended = source.eye_gain_extended_0_5;
    eye_gain_extended = source.eye_gain_extended;
    
    n_conds = size(source.mu, 1);
    n_parts = size(source.mu, 2);
    
    % Restructure psychometrics (mu)
    data.mur = ones(size(mu)) * 0.1;
    data.mup = mu;
    
    data.mu1(1:2:n_conds, :) = data.mur(1:2:n_conds, :);
    data.mu1(2:2:n_conds, :) = data.mup(2:2:n_conds, :);
    
    data.mu2(1:2:n_conds, :) = data.mup(1:2:n_conds, :);
    data.mu2(2:2:n_conds, :) = data.mur(2:2:n_conds, :);
    
    % Restructure eye movement data
    if n_conds == 12
        mmtx = [1, 2, 2, 1, 3, 4, 4, 3, 5, 6, 6, 5];
    else
        mmtx = [1, 2, 2, 1, 3, 4, 4, 3];
    end
    
    % Fixation depth
    depth = eye_gain_extended.depth(:, :, 1);
    data.depth1 = repmat(depth(:, mmtx)', 1, n_parts);
    depth = eye_gain_extended.depth(:, :, 2);
    data.depth2 = repmat(depth(:, mmtx)', 1, n_parts);
    
    data.depthr(1:2:n_conds, :) = data.depth1(1:2:n_conds, :);
    data.depthr(2:2:n_conds, :) = data.depth2(2:2:n_conds, :);
    
    data.depthp(1:2:n_conds, :) = data.depth2(1:2:n_conds, :);
    data.depthp(2:2:n_conds, :) = data.depth1(2:2:n_conds, :);
    
    % Eye movement gain
    eye = squeeze(eye_gain_extended.gain(:, :, 1));
    data.eye_gain1 = eye(:, mmtx)';
    
    eye = squeeze(eye_gain_extended.gain(:, :, 2));
    data.eye_gain2 = eye(:, mmtx)';
    
    data.eye_gainr(1:2:n_conds, :) = data.eye_gain1(1:2:n_conds, :);
    data.eye_gainr(2:2:n_conds, :) = data.eye_gain2(2:2:n_conds, :);
    
    data.eye_gainp(1:2:n_conds, :) = data.eye_gain2(1:2:n_conds, :);
    data.eye_gainp(2:2:n_conds, :) = data.eye_gain1(2:2:n_conds, :);
end
