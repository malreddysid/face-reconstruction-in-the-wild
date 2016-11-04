

load warpedFrontImages.mat

nfiles = size(images, 3);

[R,C] = size(images(:,:,1));

ReIm = reshape(images,[R*C nfiles]);

[output,S,L] = rankFourApprox(double(ReIm'));

[ReIm4rank] = reshape(output',[R C nfiles]);


% for ii=1:nfiles
%    imshow(uint8(ReIm4rank(:,:,ii)));
%    k = 0;
% end

% Re- estimating the Lighting matrix%
L_re_est = output/S;

% Template surface
A = pcread('template_cropped.ply');
N_count = A.Count;
Loc = A.Location;
map = zeros(90,90,2);

for i = 1:N_count
    x = Loc(i,1);
    y = Loc(i,2);
    z = Loc(i,3);
    if z > map(x,y,2)
        map(x,y,1) = i;
        map(x,y,2) = z;
    end
 end


B = pcnormals(A);
count = 1;
for x = 1:90
    for y = 1:90
        if(map(x,y,1)>0)
            Top_norm(count,:) = B(map(x,y,1),:);
            Snew(:,count) = S(:,y+(x-1)*90);
            count = count + 1;
        end
    end
end

[N,~] = size(Top_norm);
Template_sur = [ones(N,1) Top_norm]';


%Ambiguity recovery
A = Template_sur/Snew;

L = L*pinv(A);
S = A*S;




