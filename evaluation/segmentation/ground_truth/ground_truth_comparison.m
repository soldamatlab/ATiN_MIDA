function [segError, absError, relError] = ground_truth_comparison(Config, mriSegmented, mriPrepro)
% GROUND_TRUTH_COMPARISON compares MRI segmentation with an 8-layer
% manually segmented MRI from SCI.
% 
% Config.mriSegmented.path = path to .mat file as string
%                            The .mat file has to contain 'mriSegmented' var.
%                          or
% Config.mriSegmented.data = segmented mri as variable outputed from
%                            one of the toolboxes

%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\..\..\..\common']));
addpath(genpath(wd));

SCI_DATA_PATH = [wd '\..\..\..\data\SCI'];
GT_PATH = [SCI_DATA_PATH '\Segmentation\HeadSegmentation.nrrd'];
GT_PREPRO_PATH = [SCI_DATA_PATH '\T1\T1_Corrected.nrrd'];
const_conductivity;

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip);
ft_defaults

check_required_field(Config, 'output');
segName = [Config.mriSegmented.method sprintf('%d',Config.mriSegmented.nLayers)];
[outPath, imgPath] = create_output_folder([Config.output '\' segName], true);

check_required_field(Config, 'mriSegmented');
check_required_field(Config.mriSegmented, 'method');
check_required_field(Config.mriSegmented, 'nLayers');

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load MRIs
mriSegmented = load_mri_anytype(mriSegmented, 'mriSegmented');
mriPrepro = load_mri_anytype(mriPrepro, 'mriPrepro');

cfg = struct;
cfg.unit = 'mm';
groundTruth = load_nrrd_mri(GT_PATH, cfg);
groundTruthPrepro = load_nrrd_mri(GT_PREPRO_PATH, cfg);

cfg = struct;
cfg.method = Config.mriSegmented.method;
cfg.nLayers = Config.mriSegmented.nLayers;
mriSegmented = ensure_tissue_and_masks(cfg, mriSegmented);

cfg = struct;
cfg.method = 'SCI';
groundTruth = ensure_tissue_and_masks(cfg, groundTruth);

%% Visualize Ground Truth
cfg = struct;
cfg.colormap = [white(1); lines(7); spring(1)]; % TODO better colors
cfg.name = 'Ground Truth';
cfg.save = [imgPath '\ground_truth'];
cfg.visualize = visualize;
plot_segmentation(cfg, groundTruth, groundTruthPrepro);

%% Visualize Ground Truth Masks % TODO
%tissue = SCI_LABEL{1};
%cfg = struct;
%cfg.name = tissue;
%cfg.parameter = tissue;
%fig = plot_mask(cfg, groundTruth);

%% Allign Segmented MRI to Ground Truth
cfg = struct;
cfg.mriSegmented = mriSegmented;
cfg.mriPrepro = mriPrepro;
cfg.groundTruthPrepro = groundTruthPrepro;
[mriPrepro, mriSegmented] = align_spm_volumes(cfg);

%% Visualize Segmented MRI
cfg = struct;
cfg.name = 'Segmented MRI';
cfg.save = [imgPath '\mriSegmented_GTanatomy'];
cfg.visualize = visualize;
if isfield(Config.mriSegmented, 'colormap')
    cfg.colormap = Config.mriSegmented.colormap;
end
plot_segmentation(cfg, mriSegmented, groundTruthPrepro);

%% Interpolate tissue meshes to match
mriSegmented = interpolate_tissue(Config.mriSegmented, mriSegmented, groundTruth);

%% Join + re-number layers to match
[mriSegmented, groundTruth] = match_layers(Config.mriSegmented, mriSegmented, groundTruth);

%% Compare Segmented MRI with Ground Truth
result = evaluate_segmentation(mriSegmented, groundTruth);

%% Save Results
filename = [outPath '\' segName '_result.mat'];
save(filename, 'result', 'Config', 'mriSegmented', 'groundTruth');

%% Print Results
print_results(Config, result, groundTruth.tissuelabel);
end
