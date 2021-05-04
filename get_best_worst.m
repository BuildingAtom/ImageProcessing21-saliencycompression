function results = get_best_worst(ssimd, psnrd, msed, qd)

dssim = [ssimd(:,1) - ssimd(:,2), ssimd(:,3) - ssimd(:,4)];
dpsnr = [psnrd(:,1) - psnrd(:,2), psnrd(:,3) - psnrd(:,4)];
dmse = [msed(:,1) - msed(:,2), msed(:,3) - msed(:,4)];

[best_ssim, best_ssim_idx] = max(dssim);
[worst_ssim, worst_ssim_idx] = min(dssim);

[best_psnr, best_psnr_idx] = max(dpsnr);
[worst_psnr, worst_psnr_idx] = min(dpsnr);

[best_mse, best_mse_idx] = min(dmse);
[worst_mse, worst_mse_idx] = max(dmse);

[lowest_q, lowest_q_id] = min(qd);
[highest_q, highest_q_id] = max(qd);

results=[];
for i=1:2
results(i).best_ssim = best_ssim(i);
results(i).best_ssim_idx = best_ssim_idx(i);
results(i).worst_ssim = worst_ssim(i);
results(i).worst_ssim_idx = worst_ssim_idx(i);
results(i).best_psnr = best_psnr(i);
results(i).best_psnr_idx = best_psnr_idx(i);
results(i).worst_psnr = worst_psnr(i);
results(i).worst_psnr_idx = worst_psnr_idx(i);
results(i).best_mse = best_mse(i);
results(i).best_mse_idx = best_mse_idx(i);
results(i).worst_mse = worst_mse(i);
results(i).worst_mse_idx = worst_mse_idx(i);
results(i).lowest_q = lowest_q(i);
results(i).lowest_q_id = lowest_q_id(i);
results(i).highest_q = highest_q(i);
results(i).highest_q_id = highest_q_id(i);

results(i).dssim = dssim(:,i);
results(i).dpsnr = dpsnr(:,i);
results(i).dmse = dmse(:,i);
results(i).qd = qd(:,i);
end
end