function plot_actual_vs_expected_pse(model)

    global global_config;

    if nargin < 1
        model = 'MDL_Paper3_BW';
    end
    
    input_filename = fullfile(global_config.models_directory, model);
    output_filename = fullfile(global_config.report_directory, [model '.png']);
    
    model = load(input_filename);

    conds = {'Conditions', 'Participants'};
    
    % Paper 3

    for type = 2
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
            
            subplot(1, 2, paper);
            cla; hold on;

            axis equal
            
            if type == 1
                plot(X, Y, 'x', 'LineWidth', 5);
            else
                plot(X', Y', 'x', 'LineWidth', 5);
            end

            
            b = [0 0.25];
            line(b, b, 'LineStyle', '--', 'LineWidth', 2, 'Color', 'Black');
            
            lsline;
            
            xlabel('Actual PSE');
            ylabel('Predicted PSE');
            
            xlim([0 0.25]);
            ylim([0 0.25]);
            
            title(sprintf('Paper %d: %s', paper + 2));
        end
    end
    
    set_dims(gcf, [560 300], 'paper');
    print(gcf, '-dpng', output_filename);
end

function r = ifc(c, a, b)
    if(c)
        r = a;
    else
        r = b;
    end
end