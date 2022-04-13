function [Result, MaskResult] = compare_segmentations(Config)
% COMPARE_SEGMENTATIONS aligns 'seg2' to 'seg1' and compares them.
%
%   Required:
%   Config.path.fieldtrip
%
%   Config.seg1 - struct, see below
%   Config.seg2 - struct, see below
%   Config.segX.prepro
%   Config.segX.segmentation
%   Config.segX.method
%   Config.segX.nLayers
%
%   Config.output - string, new folder named after both segmentation
%                   methods + number of layers will be made in specified
%                   destination
%
%   Optional:
%   Config.visualize
%   Config.save
%   Config.segX.colormap
%   Config.colormap

%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\..\..\..\common']));
addpath(genpath(wd));

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip);
ft_defaults

check_required_field(Config, 'seg1');
check_required_field(Config.seg1, 'prepro');
check_required_field(Config.seg1, 'segmentation');
check_required_field(Config.seg1, 'method');
check_required_field(Config.seg1, 'nLayers');

check_required_field(Config, 'seg2');
check_required_field(Config.seg2, 'prepro');
check_required_field(Config.seg2, 'segmentation');
check_required_field(Config.seg2, 'method');
check_required_field(Config.seg2, 'nLayers');

check_required_field(Config, 'output');
seg1name = [Config.seg1.method sprintf('%d',Config.seg1.nLayers)];
seg2name = [Config.seg2.method sprintf('%d',Config.seg2.nLayers)];

outPath = [char(Config.output) '\' char(seg1name) '_' char(seg2name)];
[outPath, imgPath] = create_output_folder(outPath);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load Segmentation 1
cfg = Config.seg1;
cfg.save = [imgPath '\' seg1name];
cfg.visualize = visualize;
if isfield(Config.seg1, 'colormap')
    cfg.colormap = Config.seg1.colormap;
elseif isfield(Config, 'colormap')
    cfg.colormap = Config.colormap;
end
cfg.name = seg1name;
[segmentation1, prepro1] = load_segmented_mri(cfg);

%% Load Segmentation 2
cfg = Config.seg2;
cfg.save = [imgPath '\' seg2name];
cfg.visualize = visualize;
if isfield(Config.seg2, 'colormap')
    cfg.colormap = Config.seg2.colormap;
elseif isfield(Config, 'colormap')
    cfg.colormap = Config.colormap;
end
cfg.name = seg2name;
[segmentation2, prepro2] = load_segmented_mri(cfg);

%% Allign Segmentation 2 to Segmentation 1
cfg = struct;
cfg.seg.segmentation = segmentation2;
cfg.seg.prepro = prepro2;
cfg.target.prepro = prepro1;
cfg.target.method = Config.seg1.method;
cfg.save = [imgPath '\' seg2name '_on_' seg1name '_anatomy'];
cfg.name = [seg2name ' segmentation on ' seg1name ' anatomy'];
cfg.visualize = visualize;
[prepro2, segmentation2] = align_segmented_mri(cfg);

%% Interpolate tissue meshes to match
segmentation2 = interpolate_tissue(Config.seg2, segmentation2, segmentation1);

%% Join + re-number layers to match
[segmentation1, segmentation2] = match_layers(Config, segmentation1, segmentation2);

%% Compare Segmentations
[Result, MaskResult] = evaluate_segmentation(segmentation1, segmentation2);

%% Save Results
filename = [outPath '\' seg1name '_' seg2name '_result.mat'];
save(filename, 'Result', 'Config', 'segmentation1', 'segmentation2');

%% Plot Results
cfg = struct;
cfg.method1 = Config.seg1.method;
cfg.nLayers1 = Config.seg1.nLayers;
cfg.method2 = Config.seg2.method;
cfg.nLayers2 = Config.seg2.nLayers;
cfg.label = segmentation1.tissuelabel;

cfg.title = 'Spacial Overlap index';
cfg.save = [imgPath '\spatial_overlap'];
plot_index(cfg, Result.spatialOverlap);

cfg.title = 'Dice index';
cfg.save = [imgPath '\dice'];
plot_index(cfg, Result.dice);

cfg.title = 'Jaccard index';
cfg.save = [imgPath '\jaccard'];
plot_index(cfg, Result.jaccard);
end
