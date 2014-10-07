function tmp = magic_table(tmp, c, s)
  if s == 1
    if c == 2, tmp(tmp(:, 1) == 0.05, 2) = 0; end;
    if c == 4, tmp(tmp(:, 1) == 0.05, 2) = 0; end;
    if c == 6, tmp(tmp(:, 1) == 0.27, 2) = 1; end;
    if c == 10, tmp(tmp(:, 1) == 0.15, 2) = 1; end;
  end
  
  if s == 2
    if c == 8, tmp(tmp(:, 1) < 0.015, 2) = 0; end;
  end
  
  if s == 3
    if c == 1, tmp(tmp(:, 1) > 0.25, 2) = 1; end;
    if c == 3, tmp(tmp(:, 1) == 0.1875, 2) = 1; end;
    if c == 6, tmp(tmp(:, 1) > 0.25, 2) = 1; end;
    if c == 9, tmp(tmp(:, 1) < 0.015, 2) = 0; end;
    if c == 10, tmp(tmp(:, 1) < 0.04, 2) = 0; end;
  end
  
  if s == 4
    if c == 1, tmp(tmp(:, 1) > 0.1265, 2) = 1; end;
    if c == 1, tmp(tmp(:, 1) < 0.072, 2) = 0; end;
    if c == 5, tmp(tmp(:, 1) < 0.06, 2) = 0; end;
    if c == 9, tmp(tmp(:, 1) < 0.06, 2) = 0; end;
    if c == 11, tmp(tmp(:, 1) < 0.087, 2) = 0; end;
  end
  
  if s == 6
    if c == 3, tmp(tmp(:, 1) > 0.25, 2) = 1; end;
    if c == 7, tmp(tmp(:, 1) == 0.04875, 2) = 0; end;
    if c == 11, tmp(tmp(:, 1) > 0.194, 2) = 1; end;
  end
  
  if s == 7
    if c == 2, tmp(tmp(:, 1) > 0.2, 2) = 1; end;
    if c == 8, tmp(tmp(:, 1) < 0.02, 2) = 0; end;
    if c == 10, tmp(tmp(:, 1) < 0.02, 2) = 0; end;
    if c == 11, tmp(tmp(:, 1) > 0.20, 2) = 1; end;
  end
  
  if s == 12,
    if c == 3, tmp(tmp(:, 1) > 0.162, 2) = 1; end;
  end
  
  if s == 16
    if c == 6, tmp(tmp(:, 1) > 0.26, 2) = 1; end;
  end
  
  if s == 18
    if c == 3, tmp(tmp(:, 1) < 0.045, 2) = 0; end;
  end