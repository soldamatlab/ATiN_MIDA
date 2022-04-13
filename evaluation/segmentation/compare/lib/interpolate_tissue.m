function [segmentation] = interpolate_tissue(Config, segmentation, target)
% INTERPOLATE_TISSUE
%   Required
%   Config.method
%   Config.nLayers

segmentation = remove_tissue_masks(Config, segmentation);

cfg = struct;
cfg.parameter = 'tissue';
cfg.downsample = 1; % defualt
cfg.interpmethod = 'nearest';
segmentation = ft_sourceinterpolate(cfg, segmentation, target);

segmentation = add_tissue_masks(Config, segmentation);
end
