function spl = strsplit(str, delim)
% SPL = STRSPLIT(str, delim)
%
% Splits delimited string STR into separate parts. The parts
% are returned as a cell array. The delimiter DELIM must be given.
%
% Later versions of Matlab have similar funcionality built-in,
% this file retains compatibility with versions that do not have it.
%
% Copyright 2014 Donders Institute, Nijmegen, NL
  
  delims = find(str == delim);
  
  start = [1 delims + 1];
  finish = [delims - 1 length(str)];
  
  spl = cell(1, numel(start));
  
  for i = 1:numel(start)
    spl{i} = str(start(i):finish(i));
  end
