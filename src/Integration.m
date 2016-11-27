function [Z] = Integration(S, R, C)

zx = -S(3,:)./S(4,:);
zy = -S(2,:)./S(4,:);

zx(isnan(zx)) = 0;
zy(isnan(zy)) = 0;

zx(isinf(zx)) = 0;
zy(isinf(zy)) = 0;

fx = reshape(zx,[R C]);
fy = reshape(zy,[R C]);

imagesc(fx);
figure, imagesc(fy);
figure, imshow(fx);
figure, imshow(fy);

Z = intgrad2(fx,fy);

% [x,y] = meshgrid(1:C, 1:R);
% x = reshape(x, 1, []);
% y = reshape(y, 1, []);
% z = reshape(Z, 1, []);
% pcshow(pointCloud([x;y;z;]))

end