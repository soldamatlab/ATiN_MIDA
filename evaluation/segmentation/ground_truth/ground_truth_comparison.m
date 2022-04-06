function [segError, absError, relError] = ground_truth_comparison(Config, mriSegmented)
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
addpath([wd '\lib']);

SCI_DATA_PATH = [wd '\..\..\..\data\SCI'];
GT_PATH = [SCI_DATA_PATH '\Segmentation\HeadSegmentation.nrrd'];
GT_ANATOMY_PATH = [SCI_DATA_PATH '\T1\T1_Corrected.nrrd'];
const_conductivity;

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip);
ft_defaults

check_required_field(Config, 'output'); % TODO ? change
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
mriSegmented = load_mri_anytype(mriSegmented);

cfg = struct;
cfg.unit = 'mm';
groundTruth = load_nrrd_mri(GT_PATH, cfg);
groundTruthAnatomy = load_nrrd_mri(GT_ANATOMY_PATH, cfg);

% TODO make into function
groundTruth.(SCI_LABEL{1}) = groundTruth.anatomy == 1;
groundTruth.(SCI_LABEL{2}) = groundTruth.anatomy == 2;
groundTruth.(SCI_LABEL{3}) = groundTruth.anatomy == 3;
groundTruth.(SCI_LABEL{4}) = groundTruth.anatomy == 4;
groundTruth.(SCI_LABEL{5}) = groundTruth.anatomy == 5;
groundTruth.(SCI_LABEL{6}) = groundTruth.anatomy == 6;
groundTruth.(SCI_LABEL{7}) = groundTruth.anatomy == 7;
groundTruth.(SCI_LABEL{8}) = groundTruth.anatomy == 8;

%% Visualize Ground Truth
cfg = struct;
cfg.colormap = [white(1); lines(7)]; % TODO better colors
cfg.name = 'Ground Truth';
cfg.save = [imgPath '\ground_truth'];
cfg.visualize = visualize;
plot_segmentation(cfg, groundTruth, groundTruthAnatomy);

%% Visualize Ground Truth Masks % TODO
%tissue = SCI_LABEL{1};
%cfg = struct;
%cfg.name = tissue;
%cfg.parameter = tissue;
%fig = plot_mask(cfg, groundTruth);

%% Fix Transform Matrices (for plotting)
% Fix flips and permutations of axis (works for FieldTrip and MR-TIM):
if Config.mriSegmented.method == "fieldtrip"
    %mriSegmented.transform(2,4) = -mriSegmented.transform(2,4);
    mriSegmented.transform = eye(4);
    groundTruth.transform = eye(4);
    groundTruthAnatomy.transform = eye(4);
elseif Config.mriSegmented.method == "mrtim"
    %mriSegmented.transform(2,:) = -mriSegmented.transform(2,:);
    mriSegmented.transform(2,4) = mriSegmented.transform(2,4)+3; % manually tried
    mriSegmented.transform(3,4) = mriSegmented.transform(3,4)-13; % manually tried
else % Default transformation
    warning("Segmentation methods other than FieldTrip and MR-TIM not tested. Applying default transformation to segmentation. Segmentation may not align with ground truth.")
    mriSegmented.transform(2,:) = -mriSegmented.transform(2,:);
end

%% Fix Tissue Masks
mriSegmented = add_tissue(Config.mriSegmented, mriSegmented);
mriSegmented.tissue = flip(mriSegmented.tissue, 2);
mriSegmented = add_tissue_masks(Config.mriSegmented, mriSegmented);

%% Visualize Segmented MRI
cfg = struct;
cfg.name = 'Segmented MRI';
cfg.save = [imgPath '\mriSegmented_GTanatomy'];
cfg.visualize = visualize;
if isfield(Config.mriSegmented, 'colormap')
    cfg.colormap = Config.mriSegmented.colormap;
end
plot_segmentation(cfg, mriSegmented, groundTruthAnatomy);

%% Join + Re-number Layers to Match
[seg, truth, label] = match_layers(Config.mriSegmented, mriSegmented, groundTruth);

%% Compare Segmented MRI with Ground Truth
segError = seg ~= truth;
absError = sum(segError, 'all');
relError = absError / numel(segError);

%% Print Results
fprintf("Segmentation method: %s\n", Config.mriSegmented.method)
fprintf("Number of layers:    %d\n", Config.mriSegmented.nLayers)
fprintf("______________________________\n")
fprintf("Absolute error:      %d voxels\n", absError)
fprintf("Realtive error:      %f\n", relError)

%% Save Results
filename = [outPath '\' segName '_result.mat'];
save(filename, 'absError', 'relError', 'segError', 'seg', 'truth', 'label', 'Config');

end
