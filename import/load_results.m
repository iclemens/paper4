function [data, header] = load_results(filename)
    % First read all data from file
    fid = fopen(filename, 'r');
    
    if fid < 0
      error('Unable to open file: %s', filename);
    end
    
    data = [];
    line = 1;

    while ~feof(fid)
        s = fgets(fid);
        
        if line == 1
            ntokens = sum(s == ',') + 1;
            data = cell(1, ntokens);
        end
    
        for i = 1:ntokens
            [data{line, i}, s] = strtok(s, ',');
            data{line, i} = strtrim(data{line, i});
        end
        
        line = line + 1;
    end
    
    fclose(fid);

    % Convert strings
    for i = 1:size(data, 1)
        for j = [1, 2, 8, 10]
            data{i, j} = str2double(data(i, j));
        end
    end

    % Header
    header = {'experiment', 'trial', 'ftypr', 'fdstr', 'ftypp', 'ftypp', ...
              'reford', 'mdstr', 'mdir', 'mdstp', 'response'};
end