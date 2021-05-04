%% clean up
clear all; close all;

%% load all data
% flowers
flowers_dir = dir('data/flowers');
flowers = [];
for i=3:length(flowers_dir)
    flowers = [flowers; string([flowers_dir(i).folder, '/', flowers_dir(i).name])];
end
clear flowers_dir;

% landscape
landscape_dir = dir('data/landscape');
landscape = [];
for i=3:length(landscape_dir)
    landscape = [landscape; string([landscape_dir(i).folder, '/', landscape_dir(i).name])];
end
clear landscape_dir;

% mso
mso_idx = load('data/mso/imgIdx.mat');
mso_idx = mso_idx.imgIdx;
mso_data_dir = fileparts('data/mso/MSO_img/MSO_img/COCO_COCO_train2014_000000001737.jpg');
mso = [];
mso_labels = [];
for i=1:length(mso_idx)
    mso = [mso; string([mso_data_dir, '/', mso_idx(i).name])];
    mso_labels = [mso_labels; mso_idx(i).label];
end
clear mso_idx mso_data_dir;

%% process all data
% save data so that I don't have to do this daylong step again
flower_results = process(flowers);
landscape_results = process(landscape);
mso_results = process(mso);

% they were executed seperately and combined manually
save("data");

%% analyze all data
clear all
load("data.mat");

% find the best and worse of each category
flower_bw = get_best_worst(flower_results.ssim,flower_results.psnr,flower_results.mse,flower_results.q_required);
landscape_bw = get_best_worst(landscape_results.ssim,landscape_results.psnr,landscape_results.mse,landscape_results.q_required);
mso0_bw = get_best_worst(mso_results.ssim(find(mso_labels==0),:),mso_results.psnr(find(mso_labels==0),:),mso_results.mse(find(mso_labels==0),:),mso_results.q_required(find(mso_labels==0),:));
mso1_bw = get_best_worst(mso_results.ssim(find(mso_labels==1),:),mso_results.psnr(find(mso_labels==1),:),mso_results.mse(find(mso_labels==1),:),mso_results.q_required(find(mso_labels==1),:));
mso2_bw = get_best_worst(mso_results.ssim(find(mso_labels==2),:),mso_results.psnr(find(mso_labels==2),:),mso_results.mse(find(mso_labels==2),:),mso_results.q_required(find(mso_labels==2),:));
mso3_bw = get_best_worst(mso_results.ssim(find(mso_labels==3),:),mso_results.psnr(find(mso_labels==3),:),mso_results.mse(find(mso_labels==3),:),mso_results.q_required(find(mso_labels==3),:));
mso4_bw = get_best_worst(mso_results.ssim(find(mso_labels==4),:),mso_results.psnr(find(mso_labels==4),:),mso_results.mse(find(mso_labels==4),:),mso_results.q_required(find(mso_labels==4),:));

% plot data for each
plot_all(flower_bw, flowers, "flowers");
plot_all(landscape_bw, landscape, "landscapes");
plot_all(mso0_bw, mso(find(mso_labels==0),:), "MSO 0");
plot_all(mso1_bw, mso(find(mso_labels==1),:), "MSO 1");
plot_all(mso2_bw, mso(find(mso_labels==2),:), "MSO 2");
plot_all(mso3_bw, mso(find(mso_labels==3),:), "MSO 3");
plot_all(mso4_bw, mso(find(mso_labels==4),:), "MSO 4");

%% helper function to process it all
function results = process(filenames)
% column 1 is the saliency only compression
% column 2 is the matching target quality
% column 3 is the foveate + saliency compression
% column 4 is the matching target quality
ssim_result = zeros(length(filenames),4);
psnr_result = zeros(length(filenames),4);
mse_result = zeros(length(filenames),4);
% just columns 2 and 4 as a two column result
q_required = zeros(length(filenames),2);
all_d = [];
for i=1:length(filenames)
    all_d(i).data = im2gray(imread(filenames(i)));
end
% run in parallel clusters
parfor i=1:length(filenames)
    %load the image
    im = all_d(i).data;
    % find saliency and foveate
    saliency = pft_saliency(im);
    im_foveate = foveate_saliency(im, saliency, 10);
    % compress with information
    [im_sc,size_sc] = jpeg_saliency(im, saliency, 35, 85);
    [im_fsc,size_fsc] = jpeg_saliency(im_foveate, saliency, 35, 85);
    % target
    [im_rc,~,q] = target_jpeg_size(im, size_sc);
    [im_frc,~,fq] = target_jpeg_size(im, size_fsc);
    % store metrics
    ssim_result(i,:) = [ssim(im_sc, im), ssim(im_rc, im), ssim(im_fsc, im), ssim(im_frc, im)];
    psnr_result(i,:) = [psnr(im_sc, im), psnr(im_rc, im), psnr(im_fsc, im), psnr(im_frc, im)];
    mse_result(i,:) = [immse(im_sc, im), immse(im_rc, im), immse(im_fsc, im), immse(im_frc, im)];
    q_required(i,:) = [q, fq];
end

results.ssim = ssim_result;
results.psnr = psnr_result;
results.mse = mse_result;
results.q_required = q_required;
end