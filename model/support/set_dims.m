function set_dims(h, dims, mode)
    if strcmpi(mode(1:5), 'paper')
        p = get(h, 'PaperPosition');
        p(3:4) = dims;
        set(h, 'PaperPosition', p);
    else
        p = get(h, 'Position');
        p(3:4) = dims;
        set(h, 'Position', p);
    end
end