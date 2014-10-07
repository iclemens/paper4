function mkpath(path)
  % MKPATH - Creates all directories of a given path in case they didn't already exist.
  path = strrep(path, '\', '/');  
  parts = strsplit(path, filesep());
  
  for i = 1:length(parts)
    partial_path = fullfile(parts{1:i});
    
    if isempty(parts{1})
      partial_path = ['/' partial_path];
    end

    if ~exist(partial_path, 'dir')      
      mkdir(partial_path);
    end
  end
end