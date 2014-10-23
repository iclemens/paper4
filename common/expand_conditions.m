% EXPAND_CONDITIONS(data)
%
% Expands Ab Ba into Ab bA Ba aB in order to match
% all of the 12 or 8 trial conditions (experiment 3
% and 4 respectively).

function data = expand_conditions(data)
  M = [1 2 2 1];
  n = size(data, 2) / 2;
  
  seq = ceil((1:(n*4))/4 - 1) * 2 + repmat(M, 1, n);
  
  data = data(:, seq, :);
end
