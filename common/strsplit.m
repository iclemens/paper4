function spl = strsplit(str, delim)  
  delims = find(str == delim);
  
  start = [1 delims + 1];
  finish = [delims - 1 length(str)];
  
  spl = cell(1, numel(start));
  
  for i = 1:numel(start)
    spl{i} = str(start(i):finish(i));
  end
