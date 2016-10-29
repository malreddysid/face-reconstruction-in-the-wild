function [V] = vgg_interp2(A, X, Y, interp_mode, oobv)
%
%	[V] = vgg_interp2(A, X, Y)
%	[V] = vgg_interp2(A, X, Y, interp_mode)
%	[V] = vgg_interp2(A, X, Y, interp_mode, oobv)
%
% Bilinear interpolation - similar to matlab's interp2() but with much less
% overhead. Values for locations outside of [1..H]x[1..W] are given NaN
%
%
%IN:
%	A - HxWxC double or uint8 array.
%	X - MxN column numbers
%	Y - MxN  row numbers
%	interp_mode - string, either 'linear' or 'nearest'. [def 'linear']
%	oobv - 1x1 Out of Bounds Value [def NaN]
%
%OUT:
%	V - MxNxC bilinearly interpolated values (double)

% $Id: vgg_interp2.m,v 1.6 2005/01/25 16:06:06 awf Exp $
% Yoni, Wed Jul 25 15:02:23 2001


warning(sprintf('Missing MEX-file: %s', mfilename));
