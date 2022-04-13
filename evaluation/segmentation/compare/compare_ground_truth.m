function [Result, MaskResult] = compare_ground_truth(Config)
% COMPARE_GROUND_TRUTH compares MRI segmentation with an 8-layer
% manually segmented MRI from SCI.
% 
%   Required:
%   Config.path.fieldtrip
%
%   Config.seg - struct, see below
%   Config.seg.prepro
%   Config.seg.segmentation
%   Config.seg.method
%   Config.seg.nLayers
%
%   Config.output
%
%   Optional:
%   Config.visualize
%   Config.save
%   Config.seg.colormap (same effect as Config.colormap)

%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\..\..\..\common']));
addpath(genpath(wd));

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip);
ft_defaults

% Rest will be checked by 'compare_segmentations.m'

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
cfg.seg1.colormap = [white(1); lines(7); spring(1)]; % TODO better colors

[Result, MaskResult] = compare_segmentations(cfg);
end

