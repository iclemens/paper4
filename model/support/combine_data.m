% COMBINE_DATA(data1, data2)
%
% Combines two data from two experiments
%
function data = combine_data(data1, data2)
    data = struct();
    fields = fieldnames(data1);
    
    for i = 1:numel(fields)
        data.(fields{i}) = [data1.(fields{i}), data2.(fields{i})];
    end    
end
