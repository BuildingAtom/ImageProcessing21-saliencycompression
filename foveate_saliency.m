function result = foveate_saliency(im, saliency_map, max_sigma)


% get the euclidean distance from any salient point
dist = bwdist(saliency_map);

% get gaussian blur scaling factor
scale = dist*(max_sigma/max(dist(:)));

% foveate using binning to speed up the process
[counts,values] = histcounts(scale);
result = im;
for i=2:length(counts)
    level = imgaussfilt(im, values(i));
    mask = scale>=values(i-1)&scale<values(i);
    result(mask) = level(mask);
end

end