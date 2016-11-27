pt = pcread('template_cropped.ply');
point = pt.Location;
num_points = size(point, 1);

z = zeros(90, 90);


for i = 1:num_points
    if(point(i,3) > z(point(i,1), point(i,2)))
        z(point(i,1), point(i,2)) = point(i,3);
    end
end

[x,y] = meshgrid(1:90, 1:90);

x = reshape(x, [numel(x), 1]);
y = reshape(y, [numel(y), 1]);
z = reshape(z, [numel(z), 1]);

pt2 = pointCloud([x, y, z]);
pcwrite(pt2, 'template_grid.ply');