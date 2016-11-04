%function [ptCloud] = getSurface(S, map)
% Implements 2.4 of the paper.

n1 = S(:,:,2)./S(:,:,1);
n2 = S(:,:,3)./S(:,:,1);
n3 = S(:,:,4)./S(:,:,1);

zx = -n1./n3;
zy = -n2./n3;

z = intgrad2(zx, zy);

s_x = size(zx,1);
s_y = size(zy,1);

[x,y] = meshgrid(1:s_x, 1:s_y);

x = reshape(x, [numel(x), 1]);
y = reshape(y, [numel(y), 1]);
z = reshape(z, [numel(z), 1]);

points = [x, y, z];

templateCloud = pcread('template_cropped.ply');
templatePoints = templateCloud.Location;

count = 1;
for x_1 = 1:90
    for y_1 = 1:90
        if(map(x_1,y_1,1)>0)
            count = count + 1;
        end
    end
end

template_Z = zeros(count, 1);
X_hat = zeros(count, 1);
Y_hat = zeros(count, 1);
Z_hat = zeros(count, 1);

count = 1;
for x_i = 1:90
    for y_i = 1:90
        if(map(x_i,y_i,1)>0)
            template_Z(count) = templatePoints(map(x_i,y_i,1),3);
            X_hat(count)  = x(y_i+(x_i-1)*90);
            Y_hat(count)  = y(y_i+(x_i-1)*90);
            Z_hat(count)  = z(y_i+(x_i-1)*90);
            count = count + 1;
        end
    end
end

lhs_mat = [X_hat, Y_hat, Z_hat];

A = lhs_mat\template_Z;

Z_true = A(1).*x + A(2).*y + A(3).*z;

true_points = [x, y, Z_true];

ptCloud = pointCloud(true_points);

%end

