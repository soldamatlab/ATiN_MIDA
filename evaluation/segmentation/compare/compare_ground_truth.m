function [Result, MaskResult] = compare_ground_truth(Config)
% COMPARE_GROUND_TRUTH compares MRI segmentation with an 8-layer
% manually segmented MRI from SCI. Segmentation will be aligned to the SCI
% ground truth.
% 
% Required:
%   Config.seg - struct, see below
%   Config.seg.prepro
%   Config.seg.segmentation
%   Config.seg.method
%   Config.seg.nLayers
%
%   Config.output
%
% Optional:
%   Config.visualize
%   Config.save
%   Config.seg.suffix
%   Config.seg.colormap (same effect as Config.colormap)
%   Config.noFlip       = logical, if set to true, segmentation won't be
%                         flipped to match SCI ground truth (useful when
%                         it's already flipped)

%% Import
addpath_source;

%% Config
% will be checked by 'compare_segmentations.m'

%% Load Ground Truth
cfg = struct;
cfg.visualize = false; % will be visualized in 'compare_segmentations.m'
[groundTruth, groundTruthPrepro] = load_ground_truth(cfg);

%% Compare Segmentations
cfg = Config;
cfg.seg2 = cfg.seg;
cfg = rmfield(cfg, 'seg');

cfg.seg1 = struct;
cfg.seg1.prepro = groundTruthPrepro;
cfg.seg1.segmentation = groundTruth;
cfg.seg1.method = 'SCI';
cfg.seg1.nLayers = 8;

[Result, MaskResult] = compare_segmentations(cfg);
end

