%% load an image
im = imread("data/mso/MSO_img/MSO_img/VOC_002558.jpg");
im = im2gray(im);

%% Try to create the PFT
im_ft = fft2(im);
im_p = angle(im_ft);
im_s = abs(ifft2(exp(1i.*im_p))).^2;
im_s = imgaussfilt(im_s, 8);

[counts,vals] = histcounts(im_s);
thres = otsuthresh(counts);
thres = (max(vals)-min(vals))*thres + min(vals);
im_show = im_s;
im_show(im_s<=thres) = 0;
im_show(im_s>thres) = 1;

figure
imshow(im);
figure
imshow(im_show,[]);

%% apply distance and scale for maximum blur
max_sigma = 10;
dist = bwdist(im_show);

% get gaussian blur scaling factor
scale = dist*(max_sigma/max(dist(:)));

% process each point
% result = scale;
% size_y = size(scale,1);
% size_x = size(scale,2);
% for row=1:size_y
%     for col=1:size_x
%         if ~scale(row,col)
%             result(row,col) = double(im(row,col));
%             continue
%         end
%         [x,y] = meshgrid(1-col:size_x-col, 1-row:size_y-row);
%         cinv = inv([scale(row,col),0;0,scale(row,col)]);
%         filt = exp(-.5 * (x.*(x*cinv(1,1) + y*cinv(1,2)) + y.*(x*cinv(2,1)+ y*cinv(2,2))) );
%         result(row,col) = sum(filt.*double(im),'all');
%     end
% end

[counts,values] = histcounts(scale);
result = im;
for i=2:length(counts)
    level = imgaussfilt(im, values(i));
    mask = scale>=values(i-1)&scale<values(i);
    result(mask) = level(mask);
end
figure
imshow(result,[]);
%% Find what polynomial best estimates the size
% im is expected coming into this.
% sample the whole thing
plots = [];
for i=1:100
    [~, size] = jpeg(im, i);
    plots = [plots; size];
end
% plot the actual response
figure
plot(plots);
% fit with 5 terms
i = [1:100].';
p = polyfit(i, plots, 5);
y = polyval(p, i);
hold on
plot(y);
% sample 11 points
[~, plots2] = jpeg(im, 1);
for i=1:10
    [~, size] = jpeg(im, i*10);
    plots2 = [plots2; size];
end
i = [1; [10:10:100].'];
% 5 is not as good with less points, so fit with 7
p = polyfit(i, plots2, 7);
i = [1:100].';
y = polyval(p, i);
hold on
plot(i, y);
