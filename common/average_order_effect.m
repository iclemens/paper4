% AVERAGE_ORDER_EFFECT(data)
% 
% Averages out order effect
% Requires order of conditions to be Ab bA
% The output will only consist of Ab
% Interval order will be removed

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
        0.5 * data.(fields{i})(1:2:end) + 0.5 * data.(fields{i})(2:2:end);
  end  
end