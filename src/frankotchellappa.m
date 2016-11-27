
function z = frankotchellappa(dzdx,dzdy)

% Frankt-Chellappa Algrotihm
% Input gx and gy
% Output : reconstruction
% Author: Amit Agrawal, 2005


disp('=======================================================')
disp('Solving Using Frankot Chellappa Algorithm');

if ~all(size(dzdx) == size(dzdy))
    error('Gradient matrices must match');
end

[rows,cols] = size(dzdx);


[wx, wy] = meshgrid(-pi/2:pi/(cols-1):pi/2,-pi/2:pi/(rows-1):pi/2);

% Quadrant shift to put zero frequency at the appropriate edge
wx = ifftshift(wx); wy = ifftshift(wy);

DZDX = fft2(dzdx);   % Fourier transforms of gradients
DZDY = fft2(dzdy);

% Integrate in the frequency domain by phase shifting by pi/2 and
% weighting the Fourier coefficients by their frequencies in x and y and
% then dividing by the squared frequency.  eps is added to the
% denominator to avoid division by 0.
j = sqrt(-1);

dd = wx.^2 + wy.^2;
Z = (-j*wx.*DZDX -j*wy.*DZDY)./(wx.^2 + wy.^2 + eps); 


z = real(ifft2(Z))/2;  % Reconstruction
%z = z - min(z(:));
%z = z/2;


