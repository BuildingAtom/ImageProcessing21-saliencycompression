function [im, best_size] = jpeg(im, q)
% compress the provided image with the JPEG format as described in the
% textbook on page 588. Assume grayscale. (no chroma subsampling)
%
% estimates the resulting filesize based on coding by finding the ideal
% bpp required to store the image.

% save the size
res = size(im);

% get a usable q values from the input 1-100
if (q < 50)
    q = 5000/q;
else
    q = 200 - 2*q;
end

% the quantiztaion normalization matrix
Q_mat = [16, 11, 10, 16, 24, 40, 51, 61; ...
         12, 12, 14, 19, 26, 58, 60, 55; ...
         14, 13, 16, 24, 40, 57, 69, 56; ...
         14, 17, 22, 29, 51, 87, 80, 62; ...
         18, 22, 37, 56, 68, 109, 103, 77; ...
         24, 35, 55, 64, 81, 104, 113, 92; ...
         49, 64, 78, 87, 103, 121, 120, 101; ...
         72, 92, 95, 98, 112, 100, 103, 99];

% Use the q factor to get the final quantization matrix
Q_mat = floor((q*Q_mat + 50) / 100);
Q_mat(Q_mat == 0) = 1;

% make double and offset
im = double(im) - 128;

% dct2 and idct2 blockproc functions
block_dct = @(block_struct) round(dct2(block_struct.data)./Q_mat);
block_idct = @(block_struct) idct2(block_struct.data.*Q_mat);

% find dct and quantize after normalization
im = blockproc(im,[8 8],block_dct,'PadPartialBlocks',true,'PadMethod','symmetric');
% crop
im = im(1:res(1),1:res(2));

% code the image
bpp = best_bpp(im);
best_size = ceil(bpp*numel(im));

% idct to return to image
im = blockproc(im,[8 8],block_idct,'PadPartialBlocks',true,'PadMethod','symmetric');
% crop
im = im(1:res(1),1:res(2));

%shift back and clip to uint8
im = uint8(im + 128);
end