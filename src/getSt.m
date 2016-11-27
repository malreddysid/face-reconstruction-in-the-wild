function [St] = getSt(templateZ)

[R, C, ~] = size(templateZ);
albedo = 0.3; % Assumption

templateOnFrame = zeros(R, C, 3);

for i = 1:R
    for j = 1:C
        templateOnFrame(i,j,1) = i;
        templateOnFrame(i,j,2) = j;
        templateOnFrame(i,j,3) = templateZ(i,j,3);
    end
end

[nx,ny,nz] = surfnorm(templateOnFrame(:,:,1),templateOnFrame(:,:,2),templateOnFrame(:,:,3));

normals(:,:,1) = ones(R,C) * albedo;
normals(:,:,2) = nx * albedo;
normals(:,:,3) = ny * albedo;
normals(:,:,4) = nz * albedo;

St(1,:) = reshape(normals(:,:,1), 1, []);
St(2,:) = reshape(normals(:,:,2), 1, []);
St(3,:) = reshape(normals(:,:,3), 1, []);
St(4,:) = reshape(normals(:,:,4), 1, []);

end