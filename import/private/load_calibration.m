function cal = load_calibration(experiment_id, first_block_id, display, figure_directory)
% CAL = LOAD_CALIBRATION( ... )
%
% Loads calibraiton file for session that starts with FIRST_BLOCK_ID.
% If requested, it writes the calibration performance figure into the
% FIGURE_DIRECTORY.
%
% The output structure contain the calibration data as well as
% a function to convert raw eye positions into angles.
%
  
  if nargin < 3
    display = 'none';
  end
  
  show_summary = strcmp(display, 'summary');
  show_plots = strcmp(display, 'plot');

  
  % Plot output  
  function plot_c(s, x, y, t, l)    
    mn = min([x; y]); mx = max([x; y]);

    subplot(2,2,s); title(t); hold on;    
    line([mn mx], [mn mx], 'color', 'k', 'linewidth', 2);        

    for i_trial = 1:numel(x)
      if l(i_trial) == 0
        base = 'r';
        color = [i_trial / numel(x) 0 0];
      elseif l(i_trial) == 1
        base = 'g';
        color = [0 i_trial / numel(x) 0];
      else
        base = 'b';
        color = [0 0 i_trial / numel(x)];
      end

      plot(x(i_trial), y(i_trial), [base 'o'], 'MarkerFaceColor', color, 'MarkerSize', 8);
    end

    axis equal;
  end  
  
  
  function pos = eye_position(sled_pos, coeff)
    % Returns position of left and right eye
    % given the sled position.

    pos = [-0.5, sled_pos, 1; 0.5, sled_pos, 1] * coeff;
  end


  function pos = eye_position_ideal(sled_pos, coeff)
    pos = [-0.5 * coeff(1) + sled_pos, 0, 0; +0.5 * coeff(1) + sled_pos, 0, 0];
  end

  
  function pos = light_position(worm_pos, coeff)
    % Returns position of lasers 1 and 2 given
    % the position of the worm.

    pos = [0, worm_pos, 1; 1, worm_pos, 1] * coeff;
  end


  function pos = light_position_ideal(worm_pos, coeff)
    pos = [0, 0.5, 0; 0, 0.5, coeff(1)];
  end 
  
  function angles = alt_cal_fcn(data, cleft, cright)
    angles = zeros(size(data));
    
    angles(:, 1) = data(:, 1) * cleft(1) + cleft(2);
    angles(:, 3) = data(:, 3) * cright(1) + cright(2);
  end
  
  function angles = apply_calibration(data, coeff_cal_l, coeff_cal_r)
    n = size(data, 1);
    angles = [ [data(:, 1:2) ones(n, 1)] * coeff_cal_l, [data(:, 3:4) ones(n, 1)] * coeff_cal_r];
  end

    
  global global_config;
  cal = struct();
  
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % Load eye-position file
  
  ep_file = sprintf('%s/ss%02d/block_%02d_eye_pos_out.csv', global_config.data_directory, experiment_id, first_block_id);
  
  fid = fopen(ep_file, 'r');

  if fid < 0
    error('Eye position file not found:\n"%s"\n', ep_file);    
  end
  
  cal.eye_pos_header = textscan(fid, '%[^,],%[^,],%[^,],%[^,],%s', 1);
  cal.eye_pos_header = cellfun(@(x) x{1}, cal.eye_pos_header, 'UniformOutput', 0);
  cal.eye_pos = textscan(fid, '%[^,],%f,%f,%f,%f');   
  fclose(fid);

  % Remove "RemovePen" line if present
  valid = cellfun(@(x) x(4) ~= 'o', cal.eye_pos{1});
  cal.eye_pos = cellfun(@(x) x(valid), cal.eye_pos, 'UniformOutput', 0);

  % Replace L with -1 and R with +1
  cal.eye_pos = [cellfun(@(x) strcmp(x(4), 'R'), cal.eye_pos{1}) * 2 - 1, cal.eye_pos{2:end}];
  
  % Transform coordinates
  cal.eye_pos(:, 3:5) = global_config.transform_coords( cal.eye_pos(:, 3:5) );
  
  % Remove NaN values
  cal.eye_pos(any(isnan(cal.eye_pos), 2), :) = [];
  
  % Create function to convert sled position into eye position
  Y = [cal.eye_pos(:, 3) cal.eye_pos(:, 4:5)];
  X = [0.5 * cal.eye_pos(:, 1) cal.eye_pos(:, 2) ones(size(cal.eye_pos, 1), 1)]; 
  coeff_eye = X\Y;
  
  cal.eye_pos_fcn = @(sled_pos) eye_position_ideal(sled_pos, coeff_eye);
  
  if show_summary
    fprintf('Intereye distance (cm): %.2f\n', coeff_eye(1) * 100);
    fprintf('Prediction error (mm):  %.2f\n', max(max(abs((X * coeff_eye - Y) * 1000))));
    fprintf('Alignment X: %.2f, Y: %.2f, Z: %.2f\n', abs(coeff_eye(2, :)));
  end

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load light-position file
  
  lp_file = sprintf('%s/ss%02d/block_%02d_light_pos_out.csv', global_config.data_directory, experiment_id, first_block_id);
  
  fid = fopen(lp_file);
  cal.light_pos_header = textscan(fid, '%[^,],%[^,],%[^,],%[^,],%[^,],%s', 1);
  cal.light_pos_header = cellfun(@(x) x{1}, cal.light_pos_header(2:end), 'UniformOutput', 0);
  
  cal.light_pos = textscan(fid, '%[^,],%f,%f,%f,%f,%f');
  cal.light_pos = [cal.light_pos{2:end}];  
  fclose(fid);

  % Transform coordinates
  cal.light_pos(:, 3:5) = global_config.transform_coords( cal.light_pos(:, 3:5) );
  cal.light_pos(cal.light_pos(:, 1) ~= 1 & cal.light_pos(:, 1) ~= 2, :) = [];
  
  % Remove NaN values
  cal.light_pos(any(isnan(cal.light_pos), 2), :) = [];  
  
  Y = [cal.light_pos(:, 3) cal.light_pos(:, 4:5)];
  X = [cal.light_pos(:, 1) - 1 cal.light_pos(:, 2) ones(size(cal.light_pos, 1), 1)];
  coeff_light = X\Y;
  
  cal.light_pos_fcn = @(worm_pos) light_position_ideal(worm_pos, coeff_light);
  
  if show_summary
    fprintf('Interlight distance (cm): %.2f\n', coeff_light(1) * 100);
    fprintf('Prediction error (mm):  %.2f\n', max(max(abs((X * coeff_light - Y) * 1000))));
    fprintf('Alignment X: %.2f, Y: %.2f, Z: %.2f\n', abs(coeff_light(2, :)));   
  end

  
  %%%%%%%%%%%%%%%%%%%%%%%%%
  % Load calibration files
  cl_file = sprintf('%s/ss%02d/block_%02d_calibration_out.csv', global_config.data_directory, experiment_id, first_block_id);
  rc_file = sprintf('%s/ss%02d/block_%02d_calibration_rec.csv', global_config.data_directory, experiment_id, first_block_id);
  
  if exist(rc_file, 'file')
    fprintf('Using constructed calibration file for experiment %d, block %d.\n', experiment_id, first_block_id);
    fid = fopen(rc_file);
    header = fgets(fid);
    b = textscan(fid, '%d, %f, %f');
    
    cleft = [b{2}(1) b{3}(1)];
    cright = [b{2}(2) b{3}(2)];
    
    cal.calibration_fcn = @(data) alt_cal_fcn(data, cleft, cright);
    %angles = [ [data(:, 1:2) ones(n, 1)] * coeff_cal_l, [data(:, 3:4) ones(n, 1)] * coeff_cal_r];
    
    %cal.calibration_fcn = @(data) apply_calibration(data, coeff_cal_l, coeff_cal_r);
  else
  
    fid = fopen(cl_file);
    cal.calibration_header = textscan(fid, '%[^,],%[^,],%[^,],%[^,],%[^,],%[^,],%s', 1);  
    if isempty(cal.calibration_header{1}), error('Calibration file is empty'); end;

    cal.calibration_header = cellfun(@(x) x{1}, cal.calibration_header, 'UniformOutput', 0);
    cal.calibration = textscan(fid, '%f,%f,%f,%f,%f,%f,%f');
    cal.calibration = [cal.calibration{:}];
    
    % Remove far calibration light
    cal.calibration( cal.calibration(:, 1) == 4, :) = [];
    
    fclose(fid);

    % Compute light position
    nrows = size(cal.calibration, 1);
    epl = zeros(nrows, 3);
    epr = zeros(nrows, 3);
    lp = zeros(nrows, 3);

    for i = 1:nrows
      pos = cal.eye_pos_fcn(cal.calibration(i, 3));
      epl(i, :) = pos(1, :);
      epr(i, :) = pos(2, :);

      pos = cal.light_pos_fcn(cal.calibration(i, 2));
      lp(i, :) = pos(1, :);
    end

    lpl = lp - epl;
    lpr = lp - epr;

    % Compute ideal angles
    angle_l_hv = [atan2(lpl(:, 2), lpl(:, 1)) - 0.5 * pi atan2(lpl(:, 3), lpl(:, 2))];
    angle_r_hv = [atan2(lpr(:, 2), lpr(:, 1)) - 0.5 * pi atan2(lpr(:, 3), lpr(:, 2))];

    angle_vs = (angle_l_hv + angle_r_hv) / 2;
    angle_vg = angle_r_hv - angle_l_hv;

    % Compute calibration matrices
    data_l = [cal.calibration(:, [4 5]) ones(size(cal.calibration, 1), 1)];
    data_r = [cal.calibration(:, [6 7]) ones(size(cal.calibration, 1), 1)];

    coeff_cal_l = data_l(~any(isnan(data_l), 2), :) \ angle_l_hv(~any(isnan(data_l), 2), :);
    coeff_cal_r = data_r(~any(isnan(data_r), 2), :) \ angle_r_hv(~any(isnan(data_r), 2), :);

    cal.calibration_fcn = @(data) apply_calibration(data, coeff_cal_l, coeff_cal_r);

    predicted_lr = cal.calibration_fcn(cal.calibration(:, 4:7));      

    if show_plots
      h = figure(); clf;

      plot_c(1, angle_l_hv(:, 1), predicted_lr(:, 1), 'Left Horizontal', cal.calibration(:, 1));
      plot_c(2, angle_r_hv(:, 1), predicted_lr(:, 3), 'Right Horizontal', cal.calibration(:, 1));

      plot_c(3, angle_l_hv(:, 2), predicted_lr(:, 2), 'Left Vertical', cal.calibration(:, 1));
      plot_c(4, angle_r_hv(:, 2), predicted_lr(:, 4), 'Right Vertical', cal.calibration(:, 1));

      if nargin >= 4
        filename = sprintf('%s/cal_%d_%d.eps', figure_directory, experiment_id, first_block_id);
        print(h, filename, '-depsc2');
        close(h);
      end

    end
  
  end
end
