%% load an image to test with
%test nonideal data
%im = imread("data/mso/MSO_img/MSO_img/VOC_002558.jpg");
%test better data
im = imread("punchcard.png");
im = im2gray(im);

%% find the saliency map & foveate
saliency = pft_saliency(im);
im_foveate = foveate_saliency(im, saliency, 10);

%% evaluate effect of compression on ssim and psnr
ssim_d = [];
psnr_d = [];
mse_d = [];
for i=1:100
    im_test = jpeg(im, i);
    ssim_d = [ssim_d; ssim(im_test, im)];
    psnr_d = [psnr_d; psnr(im_test, im)];
    mse_d = [mse_d; immse(im_test, im)];
end

figure
plot(ssim_d)
xlabel("Q value")
ylabel("SSIM of overall image")
title("Effect of Q value on SSIM of overall image")
figure
plot(psnr_d)
xlabel("Q value")
ylabel("PSNR of overall image")
title("Effect of Q value on PSNR of overall image")
figure
plot(mse_d)
xlabel("Q value")
ylabel("MSE of overall image")
title("Effect of Q value on MSE of overall image")

%% evaluate effect of compression on ssim and psnr when masking by saliency
ssim_d = [];
psnr_d = [];
mse_d = [];
for i=1:100
    im_test = jpeg(im, i);
    [~, vals] = ssim(im_test, im);
    ssim_d = [ssim_d; mean(vals(saliency>0))];
    psnr_d = [psnr_d; psnr(im_test(saliency>0), im(saliency>0))];
    mse_d = [mse_d; immse(im_test(saliency>0), im(saliency>0))];
end

figure
plot(ssim_d)
xlabel("Q value")
ylabel("SSIM of salient region")
title("Effect of Q value on SSIM of salient region")
figure
plot(psnr_d)
xlabel("Q value")
ylabel("PSNR of salient region")
title("Effect of Q value on PSNR of salient region")
figure
plot(mse_d)
xlabel("Q value")
ylabel("MSE of salient region")
title("Effect of Q value on MSE of salient region")

%% compress & target
[im_fc,size_fc] = jpeg(im,10);
%[im_fc,size_fc] = jpeg_saliency(im, saliency, 35, 85);

figure
imshow(im_fc)
figure

%target with regular compression
[im_rc,size_rc,q] = target_jpeg_size(im, size_fc);

ssim(im_fc, im)
psnr(im_fc, im)
ssim(im_rc, im)
psnr(im_rc, im)

imshowpair(im_fc,im_rc,'montage');

%% compress & target
%[im_fc,size_fc] = jpeg(im_foveate,10);
[im_fc,size_fc] = jpeg_saliency(im_foveate, saliency, 35, 85);

%target with regular compression
[im_rc,size_rc,q] = target_jpeg_size(im, size_fc);

ssim(im_fc, im)
psnr(im_fc, im)
ssim(im_rc, im)
psnr(im_rc, im)

imshowpair(im_fc,im_rc,'montage');
