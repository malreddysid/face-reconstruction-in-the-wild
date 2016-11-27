function [] = saveTemplateCoordinates()
% Stores the fiducial points of the 3D mesh into a .mat file

% These coordinates are for the 3D point cloud in template.ply
% templateCoordinates = [35.53, -428.7, 1152; 39.07, -456.8, 1148; 42.61, -495, 1148;...
%     39.77, -528, 1154; 85.22, -456.7, 1138; 85.77, -475.1, 1122;...
%     88.47, -490.1, 1136; 107.7, -448.1, 1147; 107.8, -499.6, 1144];
% 
% save('templateCoordinates.mat', 'templateCoordinates');

templateCoordinates = [34.9, 2.458, 1230; 37, -31.89, 1236; 45.4, -66.51, 1248;...
     41.24, -94.92, 1267; 82.49, -29.01, 1227; 80.5, -53.6, 1212;...
     79.03, -71.2, 1240; 105.5, -23.84, 1228; 111.5, -72.14, 1251];

save('templateCoordinates.mat', 'templateCoordinates');

end

