function bpp = best_bpp(im)

% flatten the array
array = double(im(:));

% get all unique values and bin them
[~,~,ic] = unique(array);
bins = accumarray(ic,1);

% use the binning to get probabilities
bins = bins./sum(bins);

bpp = -sum(bins.*log2(bins));
end