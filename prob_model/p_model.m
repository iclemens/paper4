function p_model
    global global_config;
    
    data = load('../analysis/psychometrics_p3.mat');
    

    
    
    X = linspace(0, 0.3, 20);
    clf;
    for i = 1:3
        subplot(1, 3, i); hold on;
        
        plot(X, normcdf(X, mu(i * 4 - 3), sigma(i * 4 - 3)));
        plot(X, normcdf(X, mu(i * 4 - 2), sigma(i * 4 - 2)));
        plot(X, normcdf(X, mu(i * 4 - 1), sigma(i * 4 - 1)));
        plot(X, normcdf(X, mu(i * 4 - 0), sigma(i * 4 - 0)));        
    end
    %p = get_p_longer([0.1 0.05], [0.1 0.05]);
end


function L = predict(mu, sigma)
    
    alpha * eye + (1 - a)
    
end


%
% Returns probability of 2nd longer response
%
% c1 [mu sigma] for first measurement
% c2 [mu sigma] for second mesaurement
%
function p = get_p_longer(c1, c2)
    p = normcdf(c2(1) - c1(1), 0, sqrt(c1(2) .^ 2 + c2(2) .^ 2));
end



