  function trj = world_movement(time, end_pos)
    trj = nan(length(time));        
    
    T = time / 2.0;
    trj = (80 * T .^ 3 - 240 * T .^ 4 + 192 * T .^ 5) * end_pos;
    
  end