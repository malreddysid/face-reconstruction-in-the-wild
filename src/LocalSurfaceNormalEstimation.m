function [LocalS] = LocalSurfaceNormalEstimation(L, S, M)

% Calculate how well the images fit the initial shape

threshold = 0.001;
LocalS = zeros(size(S));

numPixels = size(M, 2);
for i = 1:numPixels
   Mj = M(:,i);
   Sj = S(:,i);
   
   distance = (Mj - L*Sj).^2;
   % Normalize the distance
   if(sum(distance) ~= 0)
       distance = distance/sum(distance);
   end
   
   % Choose a subset of images for which the distance is less than a
   % threshold.
   subset = find(distance < threshold);
   Lk4 = L(subset,:);
   Mk1 = Mj(subset,:);
   if(numel(subset) < 4)
       Lk4 = L;
       Mk1 = Mj;
   end
   
   G = diag([-1, 1, 1, 1]);
   
   % Equation 3
   LocalS(:,i) = (Lk4'*Lk4 + G)\Lk4'*Mk1;
end

end