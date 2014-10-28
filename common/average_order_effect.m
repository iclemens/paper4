% AVERAGE_ORDER_EFFECT(data)
% 
% Averages out order effect
% Requires order of conditions to be Ab bA
% The output will only consist of Ab
% Interval order will be removed

function data = average_order_effect(data)  
  ql = data.ql;
  data = rmfield(data, 'ql');  
  
  w1 = 1./ql(1:2:end) ./ (1./ql(1:2:end) + 1./ql(2:2:end));
  w2 = 1./ql(2:2:end) ./ (1./ql(1:2:end) + 1./ql(2:2:end));
  
  w1 = 0.5;
  w2 = 0.5;
  
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
        w1 .* data.(fields{i})(1:2:end) + w2 .* data.(fields{i})(2:2:end);
  end  
end