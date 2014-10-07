
colors = {'r', 'b', 'g', 'c'};
names = {'EyeMovements', 'DepthCorrected', 'DepthAlpha', 'Combined'};

clf; hold on;

for j = 1:numel(names)
    m = load(sprintf('model_%s.mat', names{j}));
    d = zeros(8, 4);
    h = zeros(8, 4);
    
    for i = 1:8
        d(i, :) = 0.5 * (m.output_p4(i).data.mp(1:2:end) + m.output_p4(i).data.mp(2:2:end));
        h(i, :) = 0.5 * (m.output_p4(i).pred.mp(1:2:end) + m.output_p4(i).pred.mp(2:2:end));
    end
    
    rsq = r_squared(d(:), h(:));
    names{j} = sprintf('%s; r^2 = %.2f', names{j}, rsq);
    
    plot(d(:), h(:), [colors{j} '.']);   
end

legend(names);
axis square;
lsline;

line(xlim, xlim, 'Color', 'k');