% MRE_DISTTRANSFORM     Generalized Euclidean distance transform
%   [D,L] = mre_disttransform(I) computes the generalized Euclidean
%   distance transform of I. D returns the squared distance and
%   L returns the corresponding indices into I.
%
%   For I of class logical, the conventional binary distance transform is
%   returned
%
%   For I of class double, the generalized distance transform is returned,
%   being D(x,y)=min_{x',y') I(x',y') + (x'-x)^2+(y'-y)^2
%
%   For I of class double, range should be +/-1e100 or inf
%
%   Algorithm is due to Huttenlocher et al.
