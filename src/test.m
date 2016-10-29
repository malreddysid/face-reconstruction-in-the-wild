% Script to test the functions

%% getFiducialPoints
image = imread('../data/George_W_Bush/George_W_Bush_0001.jpg');
[boundingBoxXYS, confidence, points] = getFiducialPoints(image);
imshow(image);
hold on;
plot(points(1,:),points(2,:),'y+','markersize',10,'linewidth',2);
hold off;
axis image;
colormap gray;