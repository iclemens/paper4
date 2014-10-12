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


  % Load all BIC arrays from the current directory
  files = dir('.');
  
  Names = cell(0, 0);
  BIC = zeros(0, 8);
  
  j = 0;
  
  for i = 1:numel(files)
    if strncmp(files(i).name, 'BIC_', 4)
      name = files(i).name(5:end-4);
      bic = load(files(i).name);
      
      j = j + 1;
      
      Names{j} = name;
      BIC(j, :) = bic.BIC;
    end
  end

  
  % Find the model with the lowest BIC
  [~, I] = min(BIC);
  
  
  % Generate BIC table  
  f = fopen('report.html', 'w');
  fprintf(f, '<table>\n');
  
  % Header
  fprintf(f, '<tr>\n');
  for m = 1:numel(Names);
    fprintf(f, '<th>%s</th>\n', Names{m});
  end
  fprintf(f, '</tr>\n');
  
  % One row per participant
  for p = 1:8
    fprintf(f, '<tr>\n');
    
    % One column per model
    for m = 1:numel(Names);
      if m == I(p)
        col = 'red';
      else
        col = 'black';
      end
      
      fprintf(f, '<td style="color: %s; text-align: right;">%.0f</td>\n', col, BIC(m, p));
    end
    
    fprintf(f, '</tr>\n');
  end

  fprintf(f, '</table>\n');  
  fclose(f);
  