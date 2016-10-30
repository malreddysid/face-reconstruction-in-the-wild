x = imread('../data/George_W_Bush/George_W_Bush_0001.jpg');
x = rgb2gray(x);
xx = double(x);
y = imagesc(xx);% gives 2D image
z = mesh(xx);% gives the pixel values as 3rd dimension.