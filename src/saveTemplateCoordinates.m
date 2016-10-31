function [] = saveTemplateCoordinates()
% Stores the fiducial points of the 3D mesh into a .mat file

% These coordinates are for the 3D point cloud in template.ply
templateCoordinates = [35.53, -428.7, 1152; 39.07, -456.8, 1148; 42.61, -495, 1148;...
    39.77, -528, 1154; 85.22, -456.7, 1138; 85.77, -475.1, 1122;...
    88.47, -490.1, 1136; 107.7, -448.1, 1147; 107.8, -499.6, 1144];

save('templateCoordinates.mat', 'templateCoordinates');

end

