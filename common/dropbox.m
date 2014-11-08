function dropbox_dir = dropbox(subdirectory)
% DROPBOX Returns the path of the dropbox directory
%
% DROPBOX(SUBDIRECTORY) Returns the path to a subdirectory
%   within your dropbox folder.
%
% If Dropbox could not be found, an error is raised.
%
% Copyright 2014 Donders Institute, Nijmegen, NL
%  
    
  host_db = read_host_db();
  data = strsplit(host_db, 10);
  dropbox_dir = base_64_decode(data{2});
  
  if nargin > 0
    dropbox_dir = fullfile(dropbox_dir, subdirectory);
  end
end


function decoded = base_64_decode(encoded)
  % Constants used while decoding
  chars = ['A':'Z' 'a':'z' '0':'9' '+' '/' '='];
  mask = [63 48 0 0; 0 15 60 0; 0 0 3 63];
  shift = [2 -4 0 0; 0 4 -2 0; 0 0 6 0];
  
  % Assign values to encoded characters
  data = arrayfun(@(ch) find(ch == chars), encoded);
  data(data > 64) = 1;
  data = data - 1;

  % Loop over sets of 4 encoded characters and output 3 decoded characters
  for i = 1:(length(data) / 4)
    for j = 1:3
      positions = (i-1) * 4 + (1:4);
      decoded(i * 3 + j) =  char(sum(bitshift(bitand(data(positions), mask(j, :)), shift(j, :))));
    end
  end
  
  decoded(decoded == 0) = [];
end


function data = read_host_db()
%
% Locate and read host.db file.
%

  if exist('~/.dropbox/host.db', 'file')
    host_file = '~/.dropbox/host.db';
  elseif exist('%APPDATA%\Dropbox\host.db', 'file')
    host_file = '%APPDATA%\Dropbox\host.db';
  else
    warning('Dropbox:HostDBNotFound', 'Host.db file could not be found in the application directory.');
    host_file = uigetfile('host.db', 'Select Dropbox host.db file');
  end
  
  data = fileread(host_file);
end
