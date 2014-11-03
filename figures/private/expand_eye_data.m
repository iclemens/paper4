  function [ref, prb, first, second] = expand_eye_data(data, tp, exp)
    first = data.(sprintf('eye_%s_simple', tp)).gain';
    second = data.(sprintf('eye_%s_extended', tp)).gain(:, :, 2)';
    
    if exp == 1
      first = first([1 2 2 1 3 2 2 3 1 3 3 1], :); 
      second = second([1 2 2 1 3 4 4 3 5 6 6 5], :);
    elseif exp == 2
      first = first([1 2 2 1 3 4 4 3], :);
      second = second([1 2 2 1 3 4 4 3], :);
    end
    
    ref = nan(size(first));
    prb = nan(size(first));
    
    for i = 1:size(first, 1)
      if mod(i, 2) == 1
        ref(i, :) = first(i, :);
        prb(i, :) = second(i, :);
      else
        ref(i, :) = second(i, :);
        prb(i, :) = first(i, :);
      end      
    end
    
  end