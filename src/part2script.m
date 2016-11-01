

load warpedFrontImages.mat

nfiles = size(images, 3);

[R,C] = size(images(:,:,1));

ReIm = reshape(images,[R*C nfiles]);

[output] = rankFourApprox(double(ReIm'));

ReIm4rank = reshape(output',[R C nfiles]);


for ii=1:nfiles
   imshow(uint8(ReIm4rank(:,:,ii)));
   k = 0;
end

