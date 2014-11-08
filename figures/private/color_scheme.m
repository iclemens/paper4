function colors = color_scheme(experiment)
  if experiment == 1
    colors = [ ...
      118,  18,  20;
      213,  24,  31;
       83, 113,  56;
      147, 213,  93;
       20,  90, 129;
      125, 195, 235
      ] / 256;
  else
    colors = [ ...
      219 129 37;
      105 62 18;
      143, 29, 222;      
       66 12 103;
      ] / 256;
  end
end
