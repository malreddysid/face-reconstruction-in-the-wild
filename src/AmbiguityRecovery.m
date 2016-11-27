function [finalL, finalS] = AmbiguityRecovery(L,S,M,St)

L = M*S'*inv(S*S');
numImages = size(M,1);
threshold = 10;
selected = [];

% Select images which fit well by this low rank approximation.
for i = 1:numImages
    fit = norm(M(i,:) - L(i,:)*S);
    if(fit < threshold)
        selected = [selected; i];
    end
end


selectedM = M(selected,:);

% Estimate Abiguity

A = St*S'*inv(S*S');

% Estimate final L and S

finalL = selectedM*S'*inv(S*S')*inv(A);
finalS = A*S;


end