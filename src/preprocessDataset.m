directory = '../data/George_W_Bush/';

files = dir(directory);
numFiles = numel(files);

index = 1;
data = cell(numFiles, 1);
for i = 1:numFiles
    fileName = files(i).name
    if(fileName(1) == '.')
        continue;
    end
    image = imread([directory fileName]);
    [boundingBoxXYS, points, descriptors, success] = getFiducialPoints(image);
    image = double(image);
    image = image/255;
    if(success == 1)
        if(numel(points) == 18)
            data{index} = struct('image', image, 'points', points, 'fileName', fileName);
            index = index + 1;
        else
            fprintf('Found more than one face\n');
        end
    else
        fprintf('Unable to get fiducial points\n');
    end
end

data = data(1:index-1);
save('preProcessedDataset.mat', 'data');