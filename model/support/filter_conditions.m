function data = filter_conditions(data, conditions)
    fields = fieldnames(data);
    
    for i = 1:numel(fields)
        data.(fields{i}) = data.(fields{i})(conditions);
    end
end