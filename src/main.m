run clc;

saveTemplateCoordinates;
load('templateCoordinates.mat');

load('preProcessedDataset.mat');

templateModel = 'face_mesh_000306.ply';
ptCloud = pcread(templateModel);
templatePoints = UpsamplePtCloud(ptCloud);
%templatePoints = ptCloud.Location;

p1 = min(templatePoints(:,1));
p2 = min(templatePoints(:,2));
p3 = min(templatePoints(:,3));
templatePoints(:,1) = templatePoints(:,1) - p1;
templatePoints(:,2) = templatePoints(:,2) - p2;
templatePoints(:,3) = templatePoints(:,3) - p3;
templateCoordinates(:,1) = templateCoordinates(:,1) - p1;
templateCoordinates(:,2) = templateCoordinates(:,2) - p2;
templateCoordinates(:,3) = templateCoordinates(:,3) - p3;
templatePoints(:,1) = templatePoints(:,1)/2;
templatePoints(:,2) = templatePoints(:,2)/2;
templatePoints(:,3) = templatePoints(:,3)/2;
templateCoordinates(:,1) = templateCoordinates(:,1)/2;
templateCoordinates(:,2) = templateCoordinates(:,2)/2;
templateCoordinates(:,3) = templateCoordinates(:,3)/2;

[outputImages, templateZ] = frontalizeDataset(data, templatePoints, templateCoordinates);
M = getM(outputImages);

save('InitialM.mat', 'M', 'templateZ');

%%

load('InitialM.mat');
[R, C, ~] = size(templateZ);
[L,S] = InitialLightingAndShapeEstimation(M);
LocalS = LocalSurfaceNormalEstimation(L, S, M);
St = getSt(templateZ);
[finalL, finalS] = AmbiguityRecovery(L,LocalS,M,St);
Z = Integration(finalS, R, C);


numPixels = size(im1, 1) * size(im1, 2);
allColors = reshape(im1, [numPixels, 3]);
[x,y] = meshgrid(1:C, 1:R);
x = reshape(x, 1, []);
y = reshape(y, 1, []);
z = reshape(Z, 1, []);
ptCloud = pointCloud([x;y;z]', 'Color', allColors);
 
% %% % % Normalize S? by scaling its rows so as to have equal norms
% for i = 1:size(S, 1)
%     S(i,:) = S(i,:)/norm(S(i,:));
% end
% 
% % Construct Q. Each row of Q is constructed with quadratic terms computed from a column of S?.
% q1 = S(1,:)';
% q2 = S(2,:)';
% q3 = S(3,:)';
% q4 = S(4,:)';
% Q = [q1.*q1, q2.*q2, q3.*q3, q4.*q4, 2*q1.*q2, 2*q1.*q3, 2*q1.*q4,...
%     2*q2.*q3, 2*q2.*q4, 2*q3.*q4];
% 
% % Using SVD, construct B? to approximate the null space of Q
% [U,D,V] = svd(Q);
% b = V(:,size(V,2));
% B = [b(1), b(5), b(6), b(7); b(5), b(2), b(8), b(9); b(6), b(8), b(3), b(10);...
%     b(7), b(9), b(10), b(4)];
% 
% % Check eigenvalues of B
% [V, E] = eig(B);
% E = abs(E);
% A = sqrt(E)*V';
% 
% % Compute the structure A? S?
% S_corrected = A*S;
% S_corrected = S_corrected';
% 
% %% 
% 
% show_surfNorm(S_corrected', 1);
% 
% S = reshape(S_corrected, [R C 4]);
% 
% zx = -S(:,:,2)./S(:,:,4);
% zy = -S(:,:,3)./S(:,:,4);
% 
% zx = squeeze(zx);
% zy = squeeze(zy);
% 
% zx(isnan(zx)) = 0;
% zy(isnan(zy)) = 0;
% 
% zx(isinf(zx)) = 0;
% zy(isinf(zy)) = 0;
% 
% z = intgrad2(zx, zy);
% 
% s_x = size(z,1);
% s_y = size(z,2);
% 
% [x,y] = meshgrid(1:s_x, 1:s_y);
% 
% x = reshape(x, [numel(x), 1]);
% y = reshape(y, [numel(y), 1]);
% z = reshape(z, [numel(z), 1]);
% 
% pcshow(pointCloud([x, y, z]));