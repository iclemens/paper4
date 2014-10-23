% WEAVE(one, two)
%
% Converts first/second interval format data
% into reference/probe format. 
%
% This function requires that all even rows
% are reference first and all odd rows are
% reference second.

function [r, p] = weave(one, two)
  n_conds = numel(one);
  
  r(1:2:n_conds) = one(1:2:n_conds);
  r(2:2:n_conds) = two(2:2:n_conds);
  
  p(1:2:n_conds) = two(1:2:n_conds);
  p(2:2:n_conds) = one(1:2:n_conds);
end