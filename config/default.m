%
% Default configuration
%
% Change the settings below to match your configuration.
%

global global_config;

% Return folder within Dropbox
base_dir = dropbox('/Shared with Luc');


% Remove this line to enable configuration
global_config.DEFAULT = [];


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project specific directories

% Raw / unprocessed
global_config.data_directory = fullfile(base_dir, 'Data');

% Cache directory, prevents costly preprocessing steps
global_config.cache_directory = fullfile(base_dir, 'Cache');

% Figure directories
global_config.figure_directory_p3 = fullfile(base_dir, 'Figures3', 'Matlab');
global_config.figure_directory_p4 = fullfile(base_dir, 'Figures4', 'Matlab');


% %%%%%%%%%%%%%%%%%
% External scripts

global_config.tool_directories = {
  fullfile(dropbox(), '/Development/MATLAB/Tools/psignifit')
  };
