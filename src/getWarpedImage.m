function [ warpedImage ] = getWarpedImage(image, imageFiducialPoints, templatePath, templateFiducialPoints)
% This function take an input image and 3D point cloud and give the face of
% the person in the image warped so that the person is facing forward.

% Get transformation Matrix
q = imageFiducialPoints;
Q = templateFiducialPoints';
q_bar = sum(q,2)./9;
Q_bar = sum(Q,2)./9;
p = q - repmat(q_bar,1,9);
P = Q - repmat(Q_bar,1,9);

A = p*P'*inv(P*P');

[U,D,V] = svd([A; cross(A(1,:), A(2,:))]);

R = U*V';

yaw = atan(R(2,1)/R(1,1));
if(R(2,1) < 0 && R(1,1) < 0)
    yaw = yaw + pi;
end
pitch = atan(-R(3,1)/sqrt(R(3,2)^2 + R(3,3)^2));
roll = atan(R(3,2)/R(3,3));
if(R(3,2) < 0 && R(3,3) < 0)
    roll = roll + pi;
end

% TODO: Condition on roll to get the correct outputs.

% Rotate the point cloud

ptCloud = pcread(templatePath);
normalPoints = ptCloud.Location;
normalPoints_bar = sum(normalPoints, 1)./size(normalPoints,1);
normalPoints_normed = normalPoints - repmat(normalPoints_bar,size(normalPoints,1),1);

rotatedPoints = A*normalPoints_normed';
rotatedPoints = [rotatedPoints(1:2,:); normalPoints_normed(:,3)'];

translatedPoints = rotatedPoints + [repmat(q_bar,1,size(normalPoints,1)); zeros(size(normalPoints,1),1)'];

% Backproject the image

[index_x, index_y] = meshgrid(1:size(image, 2), 1:size(image, 1));
pixel_values = zeros(size(translatedPoints,2),3);
I_r = interp2(index_x, index_y, double(image(:,:,1)), translatedPoints(1,:), translatedPoints(2,:));
I_g = interp2(index_x, index_y, double(image(:,:,2)), translatedPoints(1,:), translatedPoints(2,:));
I_b = interp2(index_x, index_y, double(image(:,:,3)), translatedPoints(1,:), translatedPoints(2,:));
pixel_values(:,1) = I_r;
pixel_values(:,2) = I_g;
pixel_values(:,3) = I_b;

% Rotate the point cloud to face forward.

ptCloudWithColor = pointCloud(translatedPoints', 'Color', uint8(pixel_values));
affine_tform = [[R, zeros(3,1)]; zeros(1,4)];
affine_tform(4,4) = 1;

tform = affine3d(affine_tform);
ptCloudTransformed = pctransform(ptCloudWithColor, tform);
pcshow(ptCloudTransformed);

% Get the warped image from the point cloud.

finalPoints = ptCloudTransformed.Location;
finalPixelValues = ptCloudTransformed.Color;

min_x = min(finalPoints(:,1));
min_y = min(finalPoints(:,2));
finalPoints(:,1) = finalPoints(:,1) - min_x + 1;
finalPoints(:,2) = finalPoints(:,2) - min_y + 1;

max_x = uint8(max(finalPoints(:,1)));
max_y = uint8(max(finalPoints(:,2)));

warpedImage = zeros(max_x, max_y, 3);
for i = 1:size(finalPoints,1)
    warpedImage(uint8(finalPoints(i,1)), uint8(finalPoints(i,2)), :) = finalPixelValues(i,:);
end
warpedImage = warpedImage/255;

% Since the warped image has many holes, we will use median filtering to
% fill them.

for i = 1:size(warpedImage,1)
    for j = 1:size(warpedImage,2)
        if(warpedImage(i,j,1) == 0 && warpedImage(i,j,2) == 0 && warpedImage(i,j,3) == 0)
            if(i > 1 && i < size(warpedImage,1) && j > 1 && j < size(warpedImage,2))
                warpedImage(i,j,1) = median([warpedImage(i+1,j,1), warpedImage(i-1,j,1),...
                    warpedImage(i,j+1,1), warpedImage(i,j-1,1)]);
                warpedImage(i,j,2) = median([warpedImage(i+1,j,2), warpedImage(i-1,j,2),...
                    warpedImage(i,j+1,2), warpedImage(i,j-1,2)]);
                warpedImage(i,j,3) = median([warpedImage(i+1,j,3), warpedImage(i-1,j,3),...
                    warpedImage(i,j+1,3), warpedImage(i,j-1,3)]);
            end
        end
    end
end


end

