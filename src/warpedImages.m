
imagefiles = dir('../data/George_W_Bush_warped/*.jpg');      
nfiles = length(imagefiles);    % Number of files found
for ii=1:nfiles
   currentfilename = strcat('../data/George_W_Bush_warped/',imagefiles(ii).name);
   currentimage = imread(currentfilename);
   images(:,:,ii) = rgb2gray(currentimage);
end

save('warpedFrontImages.mat','images');