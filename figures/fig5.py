import scipy.io
import scipy as sp
import numpy as np

mat3 = scipy.io.loadmat('../analysis/psychometrics_p3.mat')
mat4 = scipy.io.loadmat('../analysis/psychometrics_p4.mat')

ewb1 = np.transpose(mat3['eye_gain_simple'][0][0][0])[[0, 1, 1, 0], :]
ewb2 = np.transpose(mat3['eye_gain_extended'][0][0][0])[1][[0, 1, 1, 0], :]
enf1 = np.transpose(mat4['eye_gain_simple'][0][0][0])[[0, 1, 1, 0, 2, 3, 3, 2], :]
enf2 = np.transpose(mat4['eye_gain_extended'][0][0][0])[1][[0, 1, 1, 0, 2, 3, 3, 2], :]

mbw1 = np.ones((4, 8)) * 0.1
mbw1[1, :] = mat3['mu'][1, :]
mbw1[3, :] = mat3['mu'][3, :]

mbw2 = np.ones((4, 8)) * 0.1
mbw2[0, :] = mat3['mu'][0, :]
mbw2[2, :] = mat3['mu'][2, :]

mnf1 = np.ones((8, 8)) * 0.1
mnf2 = np.ones((8, 8)) * 0.1
for r in [0, 2, 4, 6]:
  mnf1[r + 0, :] = mat4['mu'][r + 0, :]
  mnf2[r + 1, :] = mat4['mu'][r + 1, :]

print test

#    if exp == 1
#      first = first([1 2 2 1 3 2 2 3 1 3 3 1], :); 
#      second = second([1 2 2 1 3 4 4 3 5 6 6 5], :);
#    elseif exp == 2
#      first = first([1 2 2 1 3 4 4 3], :);
#      second = second([1 2 2 1 3 4 4 3], :);


#    p(2) = 1 - p(1);   
#    a = (data.interval1(ss, s) * p(1) + p(2)) .* data.mu1(ss, s);
#    b = (data.interval2(ss, s) * p(1) + p(2));
#    y = a ./ b;