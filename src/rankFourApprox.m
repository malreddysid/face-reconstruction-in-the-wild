function [M,S,L] = rankFourApprox(M)

[U,D,V] = svd(M);

DL = D(:,1:4);
DL = sqrt(DL);
DS = D(1:4,:);
DS = sqrt(DS);

L = U*DL;
S = DS*V';

M = L*S;

end