function [ratio] = masks_ratio(mask1, mask2)
%% MASKS_RATIO return mask1 / mask2 absolute volume ratio
absMask1 = sum(mask1, 'all');
absMask2 = sum(mask2, 'all');
ratio = absMask1 / absMask2;
end

