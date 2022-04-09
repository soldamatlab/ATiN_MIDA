function [mriSegmented] = interpolate_tissue(Config, mriSegmented, groundTruth)
mriSegmented = remove_tissue_masks(Config, mriSegmented);

cfg = struct;
cfg.parameter = 'tissue';
cfg.downsample = 1; % defualt
cfg.interpmethod = 'nearest';
mriSegmented = ft_sourceinterpolate(cfg, mriSegmented, groundTruth);

mriSegmented = add_tissue_masks(Config, mriSegmented);
end

