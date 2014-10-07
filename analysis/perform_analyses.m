function perform_analyses(what)
        
    if nargin < 1
        what = {'psychfuncs', 'eye_simple_only_1st', 'eye_simple_both', 'eye_extended'};
    end

    outputfiles = {'psychometrics_p3.mat', 'psychometrics_p4.mat'};
    
    for experiment = 1:2        
        fprintf('Running analyses for experiment %d\n', experiment);
        
        outputfile = outputfiles{experiment};
        
        % Load previous output if present
        has_old_data = exist(outputfile, 'file');        
        fprintf(' Checking for old data: %s\n', pick(has_old_data, 'yes', 'no'));
        
        if has_old_data
            load(outputfile); 
        end;
        
        if any(strcmp(what, 'psychfuncs'))
            fprintf(' Fitting psychometric functions\n');
            [stim_resp, fit, mu, sigma] = fit_psychfuncs(experiment);
        end
        
        if any(strcmp(what, 'eye_simple_only_1st'))
            fprintf(' Simple 1st\n');
            eye_gain_simple = collect_eye_gain('simple_only_1st', experiment);
            eye_disp_simple = collect_normalized_eye_displacement('simple_only_1st', experiment);
        end
        
        if any(strcmp(what, 'eye_simple_both'))
            fprintf(' Simple both\n');
            eye_gain_simple_2nd = collect_eye_gain('simple_both', experiment);
            eye_disp_simple_2nd = collect_normalized_eye_displacement('simple_both', experiment);
        end
        
        if any(strcmp(what, 'eye_extended'))
            fprintf(' Extended (gain / exp)\n');
            eye_gain_extended = collect_eye_gain('extended', experiment);
            
            fprintf(' Extended (gain / 0.5m)\n');
            eye_gain_extended_0_5 = collect_eye_gain('extended_0.5', experiment);
            
            fprintf(' Extended (gain / 2.0m)\n');
            eye_gain_extended_2 = collect_eye_gain('extended_2.0', experiment);
            
            fprintf(' Extended (disp)\n');
            eye_disp_extended = collect_normalized_eye_displacement('extended', experiment);
        end
                
        save(outputfiles{experiment}, 'stim_resp', 'fit', 'mu', 'sigma', ...
            'eye_gain_simple', 'eye_gain_simple_2nd', 'eye_gain_extended', ...
            'eye_disp_simple', 'eye_disp_simple_2nd', 'eye_disp_extended', ...
            'eye_gain_extended_0_5', 'eye_gain_extended_2');
    end

    function y = pick(pred, a, b)
        if pred
            y = a;
        else
            y = b;
        end
    end
end