function [im, best_size] = jpeg_saliency(im, saliency_map, min_q, max_q)
% compress the provided image with the JPEG format as described in the
% textbook on page 588. Assume grayscale. (no chroma subsampling)
%
% estimates the resulting filesize based on coding by finding the ideal
% bpp required to store the image.

% save the size
res = size(im);

% scale the saliency map to the min and max q
q_map = (max(saliency_map(:))-saliency_map)/max(saliency_map(:))*(min_q-max_q)+max_q;

% average them
avg_proc = @(block_struct) ones(size(block_struct.data))*mean(block_struct.data(:));
q_map = blockproc(q_map,[8 8],avg_proc,'PadPartialBlocks',true,'PadMethod','symmetric');
% crop
q_map = q_map(1:res(1),1:res(2));

% get a usable q values from the input 1-100
q = q_map;
q(q_map < 50) = 5000./q_map(q_map < 50);
q(q_map >= 50) = 200 - 2*q_map(q_map >= 50);

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
find_Q = @(q_map) abs(floor((mean(q_map)*Q_mat + 50) / 100) - .5)+.5;
%effectively does the same as below
%Q_mat = floor((q*Q_mat + 50) / 100);
%Q_mat(Q_mat == 0) = 1;

% make double and offset
im = double(im) - 128;
% stack the q map
im = cat(3, im, double(q));

% dct2 and idct2 blockproc functions
block_dct = @(block_struct) round(dct2(block_struct.data(:,:,1))./find_Q(block_struct.data(1,1,2)));
block_idct = @(block_struct) idct2(block_struct.data(:,:,1).*find_Q(block_struct.data(1,1,2)));

% find dct and quantize after normalization
im = blockproc(im,[8 8],block_dct,'PadPartialBlocks',true,'PadMethod','symmetric');
% crop
im = im(1:res(1),1:res(2));

% code the image
bpp = best_bpp(im);
best_size = ceil(bpp*numel(im));
% add the amount to store the quality map
bpp = best_bpp(q_map);
best_size = best_size + ceil(bpp*prod(ceil(res/8)));

% stack for decoding
im = cat(3, im, double(q));
% idct to return to image
im = blockproc(im,[8 8],block_idct,'PadPartialBlocks',true,'PadMethod','symmetric');
% crop
im = im(1:res(1),1:res(2),1);

%shift back and clip to uint8
im = uint8(im + 128);
end