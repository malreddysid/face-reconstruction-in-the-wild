function [new_locations] = UpsamplePtCloud(pc)

x_limits = pc.XLimits;
y_limits = pc.YLimits;
x1= double(linspace(x_limits(1), x_limits(2), 800))';
y1 = double(linspace(y_limits(1), y_limits(2), 1000))';
[xq, yq] = meshgrid(x1, y1);

ll = double(pc.Location);
vq = griddata(ll(:, 1), ll(:, 2), ll(:, 3), xq, yq);
vq(isnan(vq)) = 0;

p1 = reshape(xq, [], 1);
p2 = reshape(yq, [], 1);
p3 = reshape(vq, [], 1);
new_locations = [p1 p2 p3; ll];

end