function [DETS, PTS, DESCS, success] = getFiducialPoints(image)
%Get fiducial points of the face
%   Use the existing implementation

% Add the project path
addpath('../extra/CLASS_facepipe_VJ_29-Sep-08b');
run('../extra/CLASS_facepipe_VJ_29-Sep-08b/init');

% Run the function
[DETS, PTS, DESCS, success]=extfacedescs(opts,image,false);
end
