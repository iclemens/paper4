function data = average_order_effect(data)  
% AVERAGE_ORDER_EFFECT(data)
% 
% Averages across reference-first and reference-second data.
%
% This script requires that reference-second data follows 
% reference-second data with the same fixation conditions.
%
% NO ATTEMPT IS MADE TO VERIFY WHETHER THIS IS TRUE FOR YOUR DATASET!
%
% Copyright 2014 Donders Institute, Nijmegen, NL
%

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