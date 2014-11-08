function trial_info = parse_results(result)
%
% Parses line from CSV file into struct. Most fields
% are converted into numbers.
%
  
    % Extract moved distance    
    if strcmp(result{7}, 'First')
        result_d1 = result{8} / 100.0;
        result_d2 = result{10} / 100.0;
    else
        result_d1 = result{10} / 100.0;
        result_d2 = result{8} / 100.0;    
    end
  
    if strcmp(result{9}, 'Left')
        result_d1 = -result_d1;
        result_d2 = -result_d2;
    end

    trial_info.sled_distance = [result_d1, result_d2];
    trial_info.fix_distance = [NaN NaN];

    % Extract conditions
    if strcmp(result{7}, 'First')
        if strcmp(result{4}, 'Near'), trial_info.fix_distance(1) = 0.5; end;
        if strcmp(result{4}, 'Far'), trial_info.fix_distance(1) = 2.0; end;
        if strcmp(result{6}, 'Near'), trial_info.fix_distance(2) = 0.5; end;
        if strcmp(result{6}, 'Far'), trial_info.fix_distance(2) = 2.0; end;
    
        trial_info.fix_type = {lower(result{3}) lower(result{5})};

        trial_info.reference = 1;
    else
        if strcmp(result{6}, 'Near'), trial_info.fix_distance(1) = 0.5; end;
        if strcmp(result{6}, 'Far'), trial_info.fix_distance(1) = 2.0; end;       
        if strcmp(result{4}, 'Near'), trial_info.fix_distance(2) = 0.5; end;
        if strcmp(result{4}, 'Far'), trial_info.fix_distance(2) = 2.0; end;    
    
        trial_info.fix_type = {lower(result{5}) lower(result{3})};

        trial_info.reference = 2;
    end

    % Extract response
    trial_info.response = strcmp(result{11}, 'Longer');
end
