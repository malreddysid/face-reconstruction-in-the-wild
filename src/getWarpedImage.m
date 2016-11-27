function [warpedImage, TemplateZ] = getWarpedImage(image, imageFiducialPoints, templatePoints, templateFiducialPoints, InitialR, Initialt)
% This function take an input image and 3D point cloud and give the face of
% the person in the image warped so that the person is facing forward.
% Implements section 2.1 of the paper.

q = imageFiducialPoints;
Q = templateFiducialPoints';

% Subtract the mean from the points
qBar = sum(q,2)./9;
QBar = sum(Q,2)./9;
p = q - repmat(qBar,1,9);
P = Q - repmat(QBar,1,9);

% Use the equation given in the paper
A = p*P'*inv(P*P');

% Estimate translation
t = qBar - A*QBar;

% Estimate Rotation and Scale
[U,D,V] = svd([A; cross(A(1,:), A(2,:))]);

R = U*V';

S = A*R';

% Rotate, Scale and Translate the points to match the image
rotatedPoints = S*R*templatePoints';
translatedPoints = rotatedPoints + repmat(t, 1, size(templatePoints, 1));

% Backproject the image

[indexX, indexY] = meshgrid(1:size(image, 2), 1:size(image, 1));
pixelValues = zeros(size(translatedPoints,2),3);
IR = interp2(indexX, indexY, double(image(:,:,1)), translatedPoints(1,:), translatedPoints(2,:));
IG = interp2(indexX, indexY, double(image(:,:,2)), translatedPoints(1,:), translatedPoints(2,:));
IB = interp2(indexX, indexY, double(image(:,:,3)), translatedPoints(1,:), translatedPoints(2,:));
pixelValues(:,1) = IR;
pixelValues(:,2) = IG;
pixelValues(:,3) = IB;

% Crop the image to get the part of the image that fits the 3D point cloud.

minU = Inf;
maxU = 0;
minV = Inf;
maxV = 0;

for i = 1:size(pixelValues,1)
    u = round(abs(templatePoints(i,2)));
    v = round(abs(templatePoints(i,1)));
    
    if(u <= 0 || v <= 0)
        continue;
    end
    
    if(isnan(u) || isnan(v))
        continue;
    end
    
    minU = min(minU, u);
    maxU = max(maxU, u);
    minV = min(minV, v);
    maxV = max(maxV, v);
end

I = zeros(maxV, maxU, 3);
TemplateZ = zeros(maxV, maxU, 3);

minU = Inf;
maxU = 0;
minV = Inf;
maxV = 0;

for i = 1:size(pixelValues,1)
    u = round(abs(templatePoints(i,2)));
    v = round(abs(templatePoints(i,1)));
    
    if(u <= 0 || v <= 0)
        continue;
    end
    
    if(isnan(u) || isnan(v))
        continue;
    end
    
    minU = min(minU, u);
    maxU = max(maxU, u);
    minV = min(minV, v);
    maxV = max(maxV, v);
    
    pixel = pixelValues(i,:);
    I(v, u, :) = pixel;
    TemplateZ(v, u, :) = templatePoints(i,:);
end

% minU
% maxU
% minV
% maxV

warpedImage = I(minV:maxV, minU:maxU, :);
TemplateZ = TemplateZ(minV:maxV, minU:maxU, :);
