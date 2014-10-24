function perform_analyses(what)
%
% This script call all the other analysis functions and stores the result
% in the psychometrics_p#.mat file with # indicating experiment 3 or 4.
%
% Using the optional argument, you can specify which parts of the analysis
% need to run again; the psychometric fits or one of the eye movement
% analyses.
%

    if nargin < 1
        what = {'psychfuncs', 'eye_extended'};
    end

    outputfiles = {'psychometrics_p3.mat', 'psychometrics_p4.mat'};

    for experiment = 1:2        
        fprintf('Running analyses for experiment %d\n', experiment);

        outputfile = outputfiles{experiment};

        % Load previous output if present
        has_old_data = exist(outputfile, 'file');        
        fprintf(' Checking for old data: %s\n', pick(has_old_data, 'yes', 'no'));

        if has_old_data
            data = load(outputfile);
            stim_resp = data.stim_resp;
            fit = data.fit;
            mu = data.mu;
            sigma = data.sigma;
            eye_gain_extended = data.eye_gain_extended;
        end;

        if any(strcmp(what, 'psychfuncs'))
            fprintf(' Fitting psychometric functions\n');
            [stim_resp, fit, mu, sigma, collapsed] = fit_psychfuncs(experiment);
        end        

        if any(strcmp(what, 'eye_extended'))
            fprintf(' Extended (gain / exp)\n');
            eye_gain = collect_eye_gain('extended', experiment);

            %fprintf(' Extended (disp)\n');
            %eye_disp_extended = collect_normalized_eye_displacement('extended', experiment);
        end

        save(outputfiles{experiment}, 'stim_resp', 'fit', 'mu', 'sigma', 'eye_gain');
    end

    function y = pick(pred, a, b)
        if pred
            y = a;
        else
            y = b;
        end
    end
end
