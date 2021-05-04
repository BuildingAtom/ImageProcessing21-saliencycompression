function saliency_region = pft_saliency(im)
% Find the saliency map first by using PFT method.
% Matches the paper by Guo et al. at doi:10.1109/CVPR.2008.4587715
% Then theshold this map by Otsu's method to obtain a clear segmentation

% get the fourier transform, phase, and saliency map
im_ft = fft2(im);
im_p = angle(im_ft);
im_s = abs(ifft2(exp(1i.*im_p))).^2;
im_s = imgaussfilt(im_s, 8);

% threshold using otsu (empirically more stable than choosing a factor to
% multiply by the mean value as Hou et al. did in
% doi:10.1109/CVPR.2007.383267)
[counts,vals] = histcounts(im_s);
thres = otsuthresh(counts);
thres = (max(vals)-min(vals))*thres + min(vals);
saliency_region = im_s;
saliency_region(im_s<=thres) = 0;
saliency_region(im_s>thres) = 1;

end