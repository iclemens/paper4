function cut = sort_n_cut(X, perc)

    X = sort(X);
    N = numel(X);

    one_side = (1 - perc) / 2;

    n = N * one_side;
    cut = X(ceil(n):(N - ceil(n)));
