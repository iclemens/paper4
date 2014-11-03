function initialize()
%
% Sets up path and global variables
%

  fprintf('\n');


  % Add source directories to path
  try
    [p, null, null] = fileparts(mfilename('fullpath'));
  catch
    [p, null, null] = fileparts(which('initialize'));
  end
	
  addpath(fullfile(p, 'import'));
  addpath(fullfile(p, 'analysis'));
  addpath(fullfile(p, 'common'));
  addpath(fullfile(p, 'common', 'rm_anova2'));
  addpath(fullfile(p, 'config'));

  % Get computer ID
  computer_id = get_computer_id();
  fprintf('Loading configuration for computer ID:\n %s\n', computer_id);
  

  % Load configuration if present
  global global_config;
  global_config = struct();
  
  % Common / default configuration
  common();
  
  % Custom configuration
  config_file = ['config/' computer_id '.m'];
  
  
  if exist(config_file, 'file')
    config = fileread(config_file);
    eval(config);    
  end
  
  
  % Configuration does not exist for this machine, ask to change
  if ~exist(config_file, 'file') || isfield(global_config, 'DEFAULT')
    fprintf('\nWarning: system specific configuration not found.\n\n');
    fprintf('The editor will now be launched, please change the\n');
    fprintf('default settings and run initialize again.\n');
    
    copyfile('config/default.m', config_file);
    edit(config_file);
  end

  
  % Add tool directories to path
  for i = 1:numel(global_config.tool_directories)
    addpath(global_config.tool_directories{i});
    
    fprintf('Directory: %s\n', global_config.tool_directories{i});
  end
  
  fprintf('\n');
end
