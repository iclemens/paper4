function compare_models()
%
% Generates a report that compares the parameters
% values of all models and for every participant.
%
% This script will write the model_params.html file to
% the reports directory.
%
  
  global global_config;
  
  dir_name = global_config.models_directory;
  
  % Load all models from the models directory
  files = dir(dir_name);
  n_models = 0;
  
  for i = 1:numel(files)
    if strncmp(files(i).name, 'MDL_', 4)
      n_models = n_models + 1;
      
      name = files(i).name(5:end-4);
      models{n_models} = load(fullfile(dir_name, files(i).name));
      models{n_models}.name = name;
    end
  end
  
  filename = fullfile(global_config.report_directory, 'model_params.html');
  f = fopen(filename, 'w');
  fprintf(f, '<html><head>');
  fprintf(f, '<style>th, tr { padding-right: 10px; padding-left: 10px; } th { border-bottom: 1px solid black; } th {text-align: center; } td {text-align: right; }</style>');
  fprintf(f, '</head><body>\n');
  fprintf(f, '<h1>Models papers 3 and 4</h1>\n');
  fprintf(f, '<p>Automatically generated on %s.</p>\n', date());
    
  fprintf(f, '<h2>Models</h2>\n');
  for i = 1:numel(models)
    fprintf(f, '<h3>%s</h3>\n', models{i}.name);
    fprintf(f, '<table><tr><td>');
    write_param_table(f, models{i});
    fprintf(f, '</td><td><a href="MDL_');
    fprintf(f, models{i}.name);
    fprintf(f, '.png"><img height="300" src="MDL_');
    fprintf(f, models{i}.name);
    fprintf(f, '.png" /></a></td></tr></table>');
  end
  
  fprintf(f, '</body></html>\n');
  fclose(f);
  
  fprintf('Written "%s"\n', filename);  
end


function write_param_table(f, model)
  fprintf(f, '<table>\n');
  
  % Header
  fprintf(f, '<tr>\n');
  fprintf(f, '<th>Part.</th>\n');
  for l = 1:numel(model.labels);
    fprintf(f, '<th>%s</th>\n', model.labels{l});
  end
  fprintf(f, '<th></th><th>R<sup>2</sup></th>\n');
  fprintf(f, '</tr>\n');
  
  for p = 1:8
    fprintf(f, '<tr>\n');
    fprintf(f, '<td>%d</td>\n', p);
    
    for l = 1:numel(model.labels)
      fprintf(f, '<td style="text-align: right">%.2f</td>\n', model.params(p, l));
    end
    fprintf(f, '<td style="padding-left: 30px;"></td>');
%    fprintf(f, '<td style="text-align: right">%.0f</td>\n', model.BIC(p));
    fprintf(f, '<td style="text-align: right">%.2f</td>\n', model.Rsq(p));
    
    
    fprintf(f, '</tr>\n');
  end
  
  fprintf(f, '</table>\n');  
end
