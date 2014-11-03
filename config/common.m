function common
  %
  % Configuration that does not depend on the machine.
  %
  
  global global_config;
  
  % Set coordinate transformation function
  global_config.transform_coords = @transform_coords;
  
  
  % Maps block and experiment numbers to sessions and participants
  % Participant, experiment, session, first block, last block
  global_config.sessions = [ ...
    1,  1, 1, 1, 25; 1,  1, 2, 26, 48; 1,  1, 3, 49, 70;
    2,  2, 1, 1, 30; 2,  2, 2, 31, 54; 2, 2, 3, 55, 76;
    3,  3, 1, 1, 24; 3,  3, 2, 25, 45; 3, 3, 3, 46, 67;
    4,  4, 1, 1, 33; 4,  4, 2, 34, 53; 4, 4, 3, 54, 76;
    5,  5, 1, 1, 38; 5,  5, 2, 39, 60; 5, 5, 3, 61, 89;
    6,  6, 1, 1, 36; 6,  6, 2, 37, 77; 6, 6, 3, 78, 99; 6, 6, 4, 100, 112;
    7,  7, 1, 1, 17; 7,  7, 2, 18, 35; 7, 7, 3, 36, 46;
    8,  8, 1, 1, 18; 8,  8, 2, 19, 43; 8, 8, 3, 44, 67;
    
    11, 11, 4, 1, 29; 11, 11, 5, 30, 68;
    12, 12, 4, 1, 34; 12, 12, 5, 35, 73;
    13, 13, 4, 1, 32; 13, 13, 5, 33, 64;
    14, 14, 4, 1, 31; 14, 14, 5, 32, 59;
    15, 15, 4, 1, 32; 15, 15, 5, 33, 71;
    16, 16, 5, 1, 36; 16, 16, 6, 37, 63;
    17, 17, 4, 1, 35; 17, 17, 4, 36, 70;
    18, 18, 4, 1, 34; 18, 18, 5, 35, 64
    ];
  
  
  % List of conditions in the experiment for paper 3
  global_config.conditions_p3 = { ...
    {'body',  0.5, 'world', 0.5, 1};
    {'world', 0.5, 'body',  0.5, 2};
    {'world', 0.5, 'body',  0.5, 1};
    {'body',  0.5, 'world', 0.5, 2};
    
    {'none',  0.5, 'world', 0.5, 1};
    {'world', 0.5, 'none',  0.5, 2};
    {'world', 0.5, 'none',  0.5, 1};
    {'none',  0.5, 'world', 0.5, 2};
    
    {'body',  0.5, 'none',  0.5, 1};
    {'none',  0.5, 'body',  0.5, 2};
    {'none',  0.5, 'body',  0.5, 1};
    {'body',  0.5, 'none',  0.5, 2}};
  
  
  % List of conditions in the experiment for paper 4
  global_config.conditions_p4 = { ...
    {'body', 0.5, 'body', 2.0, 1};
    {'body', 2.0, 'body', 0.5, 2};
    {'body', 2.0, 'body', 0.5, 1};
    {'body', 0.5, 'body', 2.0, 2};
    
    {'world', 0.5, 'world', 2.0, 1};
    {'world', 2.0, 'world', 0.5, 2};
    {'world', 2.0, 'world', 0.5, 1};
    {'world', 0.5, 'world', 2.0, 2}};
end

function xyz = transform_coords(xyz)
  % TRANSFORM_COORDS - Transforms XYZ coordinates such that:
  % - Sled movement is along X axis (rightward is positive)
  % - Straight ahead is the Y axis (forward is positive)
  % - Up/down is the Z axis (upward is positive)
  
  if any(xyz(:, 2) < -0.2)
    xyz = [-xyz(:, 1) xyz(:, 3), xyz(:, 2)];
  elseif any(xyz(:, 2) > 0.2)
    xyz = [xyz(:, 1) xyz(:, 2) xyz(:, 3)];
  elseif isnan(xyz)
    xyz = nan(size(xyz));
  else
    error('config:invalidcoordinates', 'Could not recognize coordinates');
  end
end
