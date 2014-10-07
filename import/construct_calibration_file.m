function construct_calibration_file(session)
  cfg = config();
  
  pixels = zeros(0, 4);
  sled = zeros(0, 1);
  angle = zeros(0, 1);

  interval = zeros(0, 1);

  for block_id = session(4):session(5)
    [trials, block_info] = load_block(session(2), block_id);
    
    for i_trial = 1:numel(trials)
      trial = trials{i_trial};
     
      [~, IstartBL] = min(abs(trial.time + 0.04));
      [~, IstopBL] = min(abs(trial.time + 0.02));
      
      [~, Istart] = min(abs(trial.time - 1.02));
      [~, Istop] = min(abs(trial.time - 1.04));      
      
      if strcmp(trial.fix_type1, 'world')
        pixels(end + 1, :) = nanmedian(trial.samples{1}(Istart:Istop, :)); % - nanmedian(trial.samples{1}(IstartBL:IstopBL, :));
        sled(end + 1, :) = trial.sled_distance1;
        
        angle(end + 1, :) = atan2(trial.sled_distance1, 0.5);
        
        interval(end + 1, :) = 1;
      end      
    end
  end
    
  
  rec_filename = sprintf('block_%02d_calibration_rec.csv', session(4));
  rec_filename = sprintf('%s/ss%02d/%s', cfg.dataDirectory, session(2), rec_filename);
  
%   fid = fopen(rec_filename, 'w');
%   fprintf(fid, 'LightID,WormPos,SledPos,EyeLX,EyeLY,EyeRX,EyeRY\n');
%   for i = 1:numel(sled)  
%     fprintf(fid, '1, 0, %.2f, %d, %d, %d, %d\n', sled(i), int32(pixels(i, 1)), int32(pixels(i, 2)), int32(pixels(i, 3)), int32(pixels(i, 4)));
%   end
%   fclose(fid);
  

  figure(1);
  clf; hold on;

  fid = fopen(rec_filename, 'w');
  fprintf(fid, 'angle = pixel * b1 + b2; pixel = (angle - b2) / b1\n');        
  
  for eye = 1:2
    column = eye * 2 - 1;
    
    a = 2.5;
    b = regress(angle, [pixels(:, column) ones(size(angle))]);  
    pixels_hat = pixels(:, column) - (angle(:, 1) - b(2)) / b(1);  
    good_trials = pixels_hat > -a * std(pixels_hat) & pixels_hat < a * std(pixels_hat);

    subplot(2,2,1 + 2 * (eye - 1));
    plot(angle(:, 1), pixels(:, column), 'r.');  
    %line(b(1) * [-4000 4000] + b(2), [-4000 4000]);

    b = regress(angle(good_trials), [pixels(good_trials, column) ones(sum(good_trials), 1)]);
    %line(b(1) * [-4000 4000] + b(2), [-4000 4000], 'color', 'r');

    subplot(2,2,2 + 2 * (eye - 1));
    plot(angle(:, 1), pixels_hat(:, 1), 'r.');

    
    fprintf(fid, '%d, %.5f, %.5f\n', eye, b(1), b(2));
  end
  
  fclose(fid);
  

%   figure(1);
%    clf;
%    subplot(2,1,1); hold on;
%    plot(angle(laser == 0, 1), pixels(laser == 0, 1), 'r.');
%    plot(angle(laser == 1, 1), pixels(laser == 1, 1), 'g.');
%    plot(angle(laser == 2, 1), pixels(laser == 2, 1), 'b.');
%    lsline;
%    subplot(2,1,2); hold on;
%    plot(angle(laser == 0, 2), pixels(laser == 0, 3), 'r.');
%    plot(angle(laser == 1, 2), pixels(laser == 1, 3), 'g.');
%    plot(angle(laser == 2, 2), pixels(laser == 2, 3), 'b.');
% 
%    lsline;
%   
%   figure(2);
%   clf; hold on;
%   plot(pixels(laser == 0, 1) ./ sled(laser == 0, 1), 'r.');
%   plot(pixels(laser == 1, 1) ./ sled(laser == 1, 1), 'g.');
%   plot(pixels(laser == 2, 1) ./ sled(laser == 2, 1), 'b.');
%    
end
