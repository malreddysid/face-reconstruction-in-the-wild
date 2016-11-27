function [outputImages, templateZ] = frontalizeDataset(data, templatePoints, templateFiducialPoints)

numData = numel(data);
outputImages = cell(numData, 1);
for i = 1:numData
    i
    image = data{i}.image;
    fiducialPoints = data{i}.points;
    [warpedImage, templateZ] = getWarpedImage(image, fiducialPoints, templatePoints, templateFiducialPoints);
    outputImages{i} = warpedImage;
end