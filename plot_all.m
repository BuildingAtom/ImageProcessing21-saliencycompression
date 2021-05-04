function plot_all(results, names, group_name)

for i=1:2
    if i==1
        name = " saliency-based compression without foveation";
        im_proc = @(im) im;
    else
        name = " saliency-based compression with foveation";
        im_proc = @(im) foveate_saliency(im, pft_saliency(im), 10);
    end
%     
%     % best ssim
    fig = figure;
%     img_helper(results(i).best_ssim_idx, names, ...
%                "Side by side of best SSIM delta " + results(i).best_ssim + " with" + name + " for " + group_name, im_proc);
%     saveas(fig, "visout/bestssim_" + group_name + "_" + i + ".png");
%     
%     % worst ssim
%     clf(fig)
%     img_helper(results(i).worst_ssim_idx, names, ...
%                "Side by side of worst SSIM delta " + results(i).worst_ssim + " with" + name + " for " + group_name, im_proc);
%     saveas(fig, "visout/worstssim_" + group_name + "_" + i + ".png");
%     
    % best psnr
    clf(fig)
    img_helper(results(i).best_psnr_idx, names, ...
               "Side by side of best PSNR delta " + results(i).best_psnr + " with" + name + " for " + group_name, im_proc);
    saveas(fig, "visout/bestpsnr_" + group_name + "_" + i + ".png");
    
%     % worst psnr
%     clf(fig)
%     img_helper(results(i).worst_psnr_idx, names, ...
%                "Side by side of worst PSNR delta " + results(i).worst_psnr + " with" + name + " for " + group_name, im_proc);
%     saveas(fig, "visout/worstpsnr_" + group_name + "_" + i + ".png");
%     
    % best mse
    clf(fig)
    img_helper(results(i).best_mse_idx, names, ...
               "Side by side of best MSE delta " + results(i).best_mse + " with" + name + " for " + group_name, im_proc);
    saveas(fig, "visout/bestmse_" + group_name + "_" + i + ".png");
%     
%     % worst mse
%     clf(fig)
%     img_helper(results(i).worst_mse_idx, names, ...
%                "Side by side of worst MSE delta " + results(i).worst_mse + " with" + name + " for " + group_name, im_proc);
%     saveas(fig, "visout/worstmse_" + group_name + "_" + i + ".png");
%     
%     % worst case where equivelent q is high
%     clf(fig)
%     img_helper(results(i).highest_q_id, names, ...
%                "Side by side of case with higest equivalent q=" + results(i).highest_q + " for" + name + " of " + group_name, im_proc);
%     saveas(fig, "visout/worstq_" + group_name + "_" + i + ".png");
%     
%     % worst ssim
%     clf(fig)
%     img_helper(results(i).lowest_q_id, names, ...
%                "Side by side of case with lowest equivalent q=" + results(i).lowest_q + " for" + name + " of " + group_name, im_proc);
%     saveas(fig, "visout/bestq_" + group_name + "_" + i + ".png");
% 
%     clf(fig)
%     histogram(results(i).dssim)
%     title("Histogram of SSIM deltas for " + group_name + " with" + name);
%     saveas(fig, "visout/ssimhist_" + group_name + "_" + i + ".png");
% 
%     clf(fig)
%     histogram(results(i).dpsnr)
%     title("Histogram of PSNR deltas for " + group_name + " with" + name);
%     saveas(fig, "visout/psnrhist_" + group_name + "_" + i + ".png");
% 
%     clf(fig)
%     histogram(results(i).dmse)
%     title("Histogram of MSE deltas for " + group_name + " with" + name);
%     saveas(fig, "visout/msehist_" + group_name + "_" + i + ".png");
% 
%     clf(fig)
%     histogram(results(i).qd)
%     title("Histogram of matching Q values for " + group_name + " with" + name);
%     saveas(fig, "visout/qhist_" + group_name + "_" + i + ".png");
    
    clear fig
end

% helper function to retrieve the images and montage them
function img_helper(idx, names, g_title, im_proc)
    im1 = im2gray(imread(names(idx)));
    [im2,size_t] = jpeg_saliency(im_proc(im1), pft_saliency(im1), 35, 85);
    im3 = target_jpeg_size(im1, size_t);
    im = cat(3, im1, im2, im3);
    montage(im, 'Size', [1 3]);
    title(g_title);
end
        
end