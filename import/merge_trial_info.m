function info1 = merge_trial_info(info1, info2)
  
  function out = close_enough(value1, value2, ignore_nan)
    if nargin < 3, ignore_nan = 0; end;
    
    if isa(value1, 'double')
      out = abs(value2 - value1) < 1e-4;      
      if ignore_nan && any(isnan(value2)), out = 1; end;      
    elseif isa(value1, 'char')
      out = strcmp(value1, value2);
      if ignore_nan && any(isnan(value2)), out = 1; end;
    elseif isa(value1, 'cell')
      out = 1;
      for j = 1:numel(value1)
        if ~close_enough(value1{j}, value2{j}, ignore_nan)
          out = 0; 
        end;
      end
    else
      disp ('Unknown type');
    end
  end
  
  fields = fieldnames(info2);
  bad_fields = {'fix_type', 'fix_distance'};
  
  for i = 1:numel(fields)
    if isfield(info1, fields{i})
      value1 = info1.(fields{i});
      value2 = info2.(fields{i});
      
      if ~close_enough(value1, value2, any(strcmp(bad_fields, fields{i})))
        fprintf('Values for field %s do not match\n', fields{i});
        
        if isa(value1, 'char')
          fprintf('"%s" != "%s"\n', value1, value2);
        elseif isa(value1, 'double')
          fprintf('%.2f != %.2f\n', value1, value2);
        else
          disp(value1);
          disp(value2);
        end
        
        info1.(fields{i}) = NaN;
      end
    else
      info1.(fields{i}) = info2.(fields{i});
    end
  end
end