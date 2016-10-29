% MRE_INTIMG_COLS   Integral image of images in columns
%   Y = MRE_INTIMG_COLS(X,[h w]) computes the integral images of images
%   stored in columns of X. The size of each image in X and Y is h x w.
%   This is equivalent to Y(:,i)=cumsum(cumsum(reshape(X(:,i),h,w),1),2)
%
%   MRE_INTIMG_COLS('X',[h w]) performs the operation in-place.
