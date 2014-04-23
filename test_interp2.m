%VGG_INTERP2  Fast 2d interpolation for images
%
%	V = vgg_interp2(A, X, Y)
%	V = vgg_interp2(A, X, Y, interp_mode)
%	V = vgg_interp2(A, X, Y, interp_mode, oobv)
%
% 2d interpolation on a regular grid - similar to matlab's interp2() but
% with much less overhead, and supports multiple channels and types. Note
% that while results of 'linear' and 'nearest' interpolation are the same
% as those of interp2(), those of cubic are not - vgg_interp2 uses a cubic
% hermite spline that is very fast to compute, unlike the natural cubic
% spline employed by interp2(), which does, however, yield a smoother
% interpolation.
%
%IN:
%	A - HxWxC double, single, uint16, uint8 or Logical array.
%	X - MxN horizontal offsets (1 being the centre of the first pixel).
%	Y - MxN vertical offsets (1 being the centre of the first pixel).
%	interp_mode - string, either 'cubic', 'linear' or 'nearest'. Default:
%	              'linear'.
%	oobv - 1x1 Out of bounds value. Default: NaN.
%
%OUT:
%	V - MxNxC interpolated values. Class is the same as that of oobv.

% $Id: vgg_interp2.m,v 1.1 2007/12/07 11:27:55 ojw Exp $



function test_interp2

[xGrid,yGrid] = meshgrid(1:2,1:2);
colorR = [20, 20; 30, 30];
colorG = [20, 40; 20, 40];
color = cat(3,colorR,colorG);

xx = vgg_interp2(color, [1.5,1.2; 1.0, 1.8], [1.5,1.3, 1.2,1.4], 'linear');


