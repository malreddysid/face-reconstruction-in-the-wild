load warpedFrontImages.mat

nfiles = size(images, 3);

%for i = 1:nfiles
%    imshow(images(:,:,i));
%    drawnow;
%    pause(1);
%end

[R,C] = size(images(:,:,1));

ReIm = reshape(images,[R*C nfiles]);
ReIm = ReIm';

M = double(ReIm);
M = M/255;

[U,D,V] = svd(M);

DL = D(:,1:4);
DL = sqrt(DL);
DS = D(1:4,:);
DS = sqrt(DS);

L = U*DL;
S = DS*V';

%{
M_4 = L*S;

[ReIm4rank] = reshape(M_4',[R C nfiles]);

for i = 1:nfiles
    imshow(ReIm4rank(:,:,i));
    drawnow;
    pause(1);
end
%}

% Normalize S? by scaling its rows so as to have equal norms
for i = 1:size(S, 2)
    S(:,i) = S(:,i)/norm(S(:,i));
end

% Construct Q. Each row of Q is constructed with quadratic terms computed from a column of S?.
q1 = S(1,:)';
q2 = S(2,:)';
q3 = S(3,:)';
q4 = S(4,:)';
Q = [q1.*q1, q2.*q2, q3.*q3, q4.*q4, 2*q1.*q2, 2*q1.*q3, 2*q1.*q4,...
    2*q2.*q3, 2*q2.*q4, 2*q3.*q4];

% Using SVD, construct B? to approximate the null space of Q
[U,D,V] = svd(Q);
b = V(:,size(V,2));
B = [b(1), b(5), b(6), b(7); b(5), b(2), b(8), b(9); b(6), b(8), b(3), b(10);...
    b(7), b(9), b(10), b(4)];

% Check eigenvalues of B
[V, E] = eig(B);
E = abs(E);
A = sqrt(E)*V';

% Compute the structure A? S?
S_corrected = A*S;
S_corrected = S_corrected';

S = reshape(S_corrected, [90 90 4]);

zx = -S(:,:,2)./S(:,:,4);
zy = -S(:,:,3)./S(:,:,4);

z = intgrad2(zx, zy);

