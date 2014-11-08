function data = expand_conditions(data)
% EXPAND_CONDITIONS(data) Expands eye movement data, which does not take
%   reference/probe intervals into account (only first vs second movement),
%   into the conditions that we actually measured.
% 
% For example, ab (only condition) would expand into (A)b (b)A.
%
% Copyright 2014 Donders Institute, Nijmegen, NL
%

  M = [1 2 2 1];
  n = size(data, 2) / 2;
  
  seq = ceil((1:(n*4))/4 - 1) * 2 + repmat(M, 1, n);
  
  data = data(:, seq, :);
end
