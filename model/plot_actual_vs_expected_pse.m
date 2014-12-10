function plot_actual_vs_expected_pse

    global global_config;

    model = 'MDL_Paper3_BW';
    
    input_filename = fullfile(global_config.models_directory, model);
    output_filename = fullfile(global_config.report_directory, [model '.png']);
    
    model = load(input_filename);

    conds = {'Conditions', 'Participants'};
    
    % Paper 3

    for type = 1:2
        for paper = 1:2
            
            % Preallocate matrices
            N = ifc(paper == 1, 6, 4);
            X = nan(8, N);
            Y = nan(8, N);
            
            % Extract data
            for i = 1:8
                if paper == 1
                    X(i, :) = model.output_p3(i).data.mp;
                    Y(i, :) = model.output_p3(i).pred.mp;
                else
                    X(i, :) = model.output_p4(i).data.mp;
                    Y(i, :) = model.output_p4(i).pred.mp;
                end
            end

            % Create plot
            
            subplot(2, 2, type * 2 + paper - 2);
            cla; hold on;

            axis equal
            
            if type == 1
                plot(X, Y, 'x', 'LineWidth', 5);
            else
                plot(X', Y', 'x', 'LineWidth', 5);
            end

            line(xlim, xlim, 'LineStyle', '--', 'Color', 'Black');

            xlabel('Actual PSE');
            ylabel('Predicted PSE');
            title(sprintf('Paper %d: %s', paper, conds{type}));

            lsline;
        end
    end
    
    print(gcf, '-dpng', output_filename);
end

function r = ifc(c, a, b)
    if(c)
        r = a;
    else
        r = b;
    end
end