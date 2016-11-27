function [L,S] = InitialLightingAndShapeEstimation(M)

numData = size(M,1);

[U,D,V] = svd(M);

R = 106;
C = 81;

DL = D(:,1:4);
DL = sqrt(DL);
DS = D(1:4,:);
DS = sqrt(DS);

L = U*DL;
S = DS*V';

% M_4 = L*S;
% 
% [ReIm4rank] = reshape(M_4',[R C numData]);
% 
% for i = 1:numData
%     imshow(ReIm4rank(:,:,i));
%     drawnow;
%     pause(1);
% end

end