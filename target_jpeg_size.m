function [im, size, quality] = target_jpeg_size(im, target_size)
% Targets a specific compression size by using the 

% Estimate the compression profile with a polynomial of 7
[~, profiles] = jpeg(im, 1);
for i=1:10
    [~, profile] = jpeg(im, i*10);
    profiles = [profiles; profile];
end
i = [1; [10:10:100].'];
p = polyfit(i, profiles, 7);

% shift down by target size and find the first intersect in the range of 1
% to 100
p(8) = p(8)-target_size;
q_int = roots(p);
% remove complex results
q_int = q_int(q_int==real(q_int));
% remove out of bounds
q_int(q_int<1) = [];
q_int(q_int>100) = [];
% select 1
q = q_int(1);
assert(q <= 100, "AAAAAA");

[im, size] = jpeg(im, q);
quality = q;
end
    