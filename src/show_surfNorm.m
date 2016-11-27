function h = show_surfNorm(S, step)
%SHOW_SURFNORM Shows the surface normals
%
%   show_surfNorm(N, step)
%
%displays the surface normals "N", a m-by-n-by-3 matrix. The density of the
%normal vectors is controlled by the sampling interval "step".
%
%Author: Xiuming Zhang (GitHub: xiumingzhang), National Univ. of Singapore
%

R = 106;
C = 81;

nx = S(2,:);%./S(1,:);
ny = S(3,:);%./S(1,:);
nz = S(4,:);%./S(1,:);

% figure;
% img(:,:,1) = nx;
% img(:,:,2) = ny;
% img(:,:,3) = nz;
% imshow(img);

nx = reshape(nx, [R, C]);
ny = reshape(ny, [R, C]);
nz = reshape(nz, [R, C]);

S_norm = zeros(R,C,3);

S_norm(:,:,1) = nx;
S_norm(:,:,2) = ny;
S_norm(:,:,3) = nz;

N = S_norm;

[im_h, im_w, ~] = size(N);

[X, Y] = meshgrid(1:step:im_w, im_h:-step:1);
U = N(1:step:im_h, 1:step:im_w, 1);
V = N(1:step:im_h, 1:step:im_w, 2);
W = N(1:step:im_h, 1:step:im_w, 3);

h = figure;
quiver3(X, Y, zeros(size(X)), U, V, W);
view([0, 90]);
axis off;
axis equal;

drawnow;
