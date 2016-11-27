function M = getM(images)

numData = numel(images);
imageSize = size(images{1}, 1) * size(images{1}, 2);
M = zeros(numData, imageSize);

for i = 1:numData
    i
    img = images{i};
    img = rgb2gray(img);
    M(i,:) = reshape(img, 1, []);
end

end