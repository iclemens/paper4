function compare_models()
%
% Generates a report that compares the BIC
% values of all models and for every participant.
%
% BIC values should be stored in the 'BIC' variable
% in files named 'BIC_[name].mat' where [name]
% represents the model name.
%
% This script will write the report.html file to
% the current directory.
%
% Structure of the report:
%  BIC Overview table
%
%  Model 1:
%   Parameters
%
%  Model 2:
%   Parameters
%


  % Load all BIC arrays from the current directory
  files = dir('data');
  n_models = 0;

  for i = 1:numel(files)
    if strncmp(files(i).name, 'BIC_', 4)
      n_models = n_models + 1;
      
      name = files(i).name(5:end-4);
      models{n_models} = load(['data/' files(i).name]);
      models{n_models}.name = name;
    end
  end

  f = fopen('report/report.html', 'w');
  fprintf(f, '<html><head>');
  fprintf(f, '<style>th, tr { padding-right: 10px; padding-left: 10px; } th { border-bottom: 1px solid black; } th {text-align: center; } td {text-align: right; }</style>');
  fprintf(f, '</head><body>\n');
  fprintf(f, '<h1>Models paper 4</h1>\n');
  fprintf(f, '<p>Automatically generated on %s.</p>\n', date());
  
  fprintf(f, '<h2>BIC Values</h2>\n');
  write_bic_table(f, models);
  
  fprintf(f, '<h2>Models</h2>\n');
  for i = 1:numel(models)
    fprintf(f, '<h3>%s</h3>\n', models{i}.name);
    write_param_table(f, models{i});
  end
  
  fprintf(f, '</body></html>\n');
  fclose(f);  
end

function BIC = create_bic_array(models)
  BIC = nan(8, numel(models));
  
  for i = 1:numel(models)
    BIC(:, i) = models{i}.BIC;
  end
end

function write_bic_table(f, models)
  BIC = create_bic_array(models);  
  [~, I] = min(BIC, [], 2);
  
  fprintf(f, '<table>\n');
  
  % Header
  fprintf(f, '<tr>\n');
  fprintf(f, '<th>Part.</th>\n');
  for m = 1:numel(models);
    fprintf(f, '<th>%s</th>\n', models{m}.name);
  end
  fprintf(f, '</tr>\n');
  
  % One row per participant
  for p = 1:8
    fprintf(f, '<tr>\n');
    
    fprintf(f, '<td>%d</td>\n', p);
    
    % One column per model
    for m = 1:numel(models);
      if m == I(p)
        col = 'red';
      else
        col = 'black';
      end
      
      fprintf(f, '<td style="color: %s; text-align: right;">%.0f</td>\n', col, BIC(p, m));
    end
    
    fprintf(f, '</tr>\n');
  end

  fprintf(f, '</table>\n');    
end

  
function write_param_table(f, model)
  fprintf(f, '<table>\n');
  
  % Header
  fprintf(f, '<tr>\n');
  fprintf(f, '<th>Part.</th>\n');
  for l = 1:numel(model.labels);
    fprintf(f, '<th>%s</th>\n', model.labels{l});
  end
  fprintf(f, '<th></th><th>BIC</th><th>R<sup>2</sup></th>\n');
  fprintf(f, '</tr>\n');
  
  for p = 1:8
    fprintf(f, '<tr>\n');
    fprintf(f, '<td>%d</td>\n', p);
    
    for l = 1:numel(model.labels)
      fprintf(f, '<td style="text-align: right">%.2f</td>\n', model.params(p, l));
    end
      fprintf(f, '<td style="padding-left: 30px;"></td>');
      fprintf(f, '<td style="text-align: right">%.0f</td>\n', model.BIC(p));
      fprintf(f, '<td style="text-align: right">%.2f</td>\n', model.Rsq(p));
    
    
    fprintf(f, '</tr>\n');
  end
  
  fprintf(f, '</table>\n');
end
