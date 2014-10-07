function out = ifc(pred, one, two)    
    out = (pred == 1) .* one + (pred ~= 1) .* two;
end