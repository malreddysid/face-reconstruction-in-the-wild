% Script to test the functions

%% getFiducialPoints
%image = imread('../data/George_W_Bush/George_W_Bush_0002.jpg');
image = imread('../data/test.jpg');
image = imresize(image, [200,200]);
[boundingBoxXYS, confidence, points] = getFiducialPoints(image);
imshow(image);
hold on;
plot(points(1,:),points(2,:),'y+','markersize',10,'linewidth',2);
%hold off;
axis image;
colormap gray;

%% getWarpedImage

saveTemplateCoordinates;

load('templateCoordinates.mat');

warpedImage = getWarpedImage(image, points, 'template.ply', templateCoordinates);

imshow(warpedImage);

%{
q = points;
Q = templateCoordinates';
q_bar = sum(q,2)./9;
Q_bar = sum(Q,2)./9;
p = q - repmat(q_bar,1,9);
P = Q - repmat(Q_bar,1,9);

A = p*P'*inv(P*P');
t = q_bar - A*Q_bar;

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


%% getTemplateFace

ptCloud = pcread('template.ply');
normalPoints = ptCloud.Location;
normalPoints_bar = sum(normalPoints, 1)./size(normalPoints,1);
normalPoints_normed = normalPoints - repmat(normalPoints_bar,size(normalPoints,1),1);
ptCloud2 = pointCloud(normalPoints_normed);
%pcshow(ptCloud2);
%hold on;

rotatedPoints = A*normalPoints_normed';
rotatedPoints = [rotatedPoints(1:2,:); normalPoints_normed(:,3)'];
ptCloud3 = pointCloud(rotatedPoints');
%pcshow(ptCloud3);
%hold on;

translatedPoints = rotatedPoints + [repmat(q_bar,1,size(normalPoints,1)); zeros(size(normalPoints,1),1)'];
ptCloud4 = pointCloud(translatedPoints');
%pcshow(ptCloud4);
%hold on;

[index_x, index_y] = meshgrid(1:size(image, 2), 1:size(image, 1));
pixel_values = zeros(size(translatedPoints,2),3);
I_r = interp2(index_x, index_y, double(image(:,:,1)), translatedPoints(1,:), translatedPoints(2,:));
I_g = interp2(index_x, index_y, double(image(:,:,2)), translatedPoints(1,:), translatedPoints(2,:));
I_b = interp2(index_x, index_y, double(image(:,:,3)), translatedPoints(1,:), translatedPoints(2,:));
pixel_values(:,1) = I_r;
pixel_values(:,2) = I_g;
pixel_values(:,3) = I_b;

flatPoints = [translatedPoints(1:2,:);zeros(1,size(translatedPoints,2))];
ptCloud5 = pointCloud(flatPoints'); 
%pcshow(ptCloud5);

ptCloud6 = pointCloud(translatedPoints', 'Color', uint8(pixel_values));
%pcshow(ptCloud6);
%hold on;

%ptCloud7 = pointCloud(flatPoints', 'Color', uint8(pixel_values)); 
%pcshow(ptCloud7);

inverse_R = inv(R);
affine_tform = [[R, zeros(3,1)]; zeros(1,4)];
affine_tform(4,4) = 1;

tform = affine3d(affine_tform);
ptCloud8 = pctransform(ptCloud6, tform);
pcshow(ptCloud8);

finalPoints = ptCloud8.Location;
finalPixelValues = ptCloud8.Color;

min_x = min(finalPoints(:,1));
min_y = min(finalPoints(:,2));
finalPoints(:,1) = finalPoints(:,1) - min_x + 1;
finalPoints(:,2) = finalPoints(:,2) - min_y + 1;

max_x = uint8(max(finalPoints(:,1)));
max_y = uint8(max(finalPoints(:,2)));

front_image = zeros(max_x, max_y, 3);
for i = 1:size(finalPoints,1)
    front_image(uint8(finalPoints(i,1)), uint8(finalPoints(i,2)), :) = finalPixelValues(i,:);
end
front_image = front_image/255;

for i = 1:size(front_image,1)
    for j = 1:size(front_image,2)
        if(front_image(i,j,1) == 0 && front_image(i,j,2) == 0 && front_image(i,j,3) == 0)
            if(i > 1 && i < size(front_image,1) && j > 1 && j < size(front_image,2))
                front_image(i,j,1) = median([front_image(i+1,j,1), front_image(i-1,j,1),...
                    front_image(i,j+1,1), front_image(i,j-1,1)]);
                front_image(i,j,2) = median([front_image(i+1,j,2), front_image(i-1,j,2),...
                    front_image(i,j+1,2), front_image(i,j-1,2)]);
                front_image(i,j,3) = median([front_image(i+1,j,3), front_image(i-1,j,3),...
                    front_image(i,j+1,3), front_image(i,j-1,3)]);
            end
        end
    end
end

imshow(front_image);
%}