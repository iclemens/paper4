% Builds mex files and copies output to parent directory

mex load_eyelink.c utils.c

outputFiles = {'load_eyelink.mexmaci64', 'load_eyelink.mexa64'};

for i = 1:numel(outputFiles);
    if exist(outputFiles{i}, 'file')
        movefile(outputFiles{i}, ['../private/' outputFiles{i}]);
    end
end
