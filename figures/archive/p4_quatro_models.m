function p4_quatro_models

   tmp = load('../analysis/model_Combined.mat');   
   tmp = load('model_Combined.mat');
   params = vertcat(tmp.output_p3(:).fit);
    
   % Alpha50, Alpha200, D50, D200
   
   a50 = params(:, 1);
   a200 = params(:, 2);
      
   AIndex = abs(a50 - a200) ./ (0.5*(a50 + a200));
   
   % 0 if equal
   %  small or large if not equal
   
   
   d50 = params(:, 3);
   d200 = params(:, 4);
   
   DIndex = abs(d200-d50) ./ (0.5 * (d200 + d50));
   
   %DIndex = (d200 - 0.5) ./ 1.5;
   

   
   
   plot(AIndex, DIndex, 'x', 'LineWidth', 3);

   xlim([0 1]); ylim([-2 2]);
   line(xlim, [0.5 0.5], 'Color', 'k', 'LineStyle', '--');
   line([0.5 0.5], ylim, 'Color', 'k', 'LineStyle', '--');

end
