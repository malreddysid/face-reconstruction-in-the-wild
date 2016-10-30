function I = pointcloud2image( x,y,z,numr,numc )
% By: Vahid Behravan
% This function converts a point cloud (given in x,y,z) to a gray scale image
% We assume the ToF camera is alligned with 'x-axis' 
%
% x,y,z: coordinate vectors of all points in the cloud
% numr: desired number of rows of output image
% numc: desired number of columns of output image
% I   : output gray scale image
%
% Example useage:
%   I = pointcloud2image( x,y,z,250,250 );
%   figure;  imshow(I,[]);
%
%------ Revision History -----------------------------------
%    ver 1.0: first release.
%    ver 1.2: normalize pixel values to [0,1] (Jan. 2016)
%-----------------------------------------------------------

% depth calculation
d = sqrt( x.^2 + y.^2 + z.^2);

% grid construction
yl = min(y); yr = max(y); zl = min(z); zr = max(z);
yy = linspace(yl,yr,numc); zz = linspace(zl,zr,numr);
[Y,Z] = meshgrid(yy,zz);
grid_centers = [Y(:),Z(:)];

% classification
clss = knnsearch(grid_centers,[y,z]); 

% defintion of local statistic
local_stat = @(x)mean(x);
%local_stat = @(x)min(x); 

% data_grouping
class_stat = accumarray(clss,d,[numr*numc 1],local_stat);

% 2D reshaping
class_stat_M  = reshape(class_stat , size(Y)); 

% Force un-filled cells to the brightest color
class_stat_M (class_stat_M == 0) = max(max(class_stat_M));

% flip image horizontally and vertically
I = class_stat_M(end:-1:1,end:-1:1);

% normalize pixel values to [0,1]
I = ( I - min(min(I)) ) ./ ( max(max(I)) - min(min(I)) );
end

