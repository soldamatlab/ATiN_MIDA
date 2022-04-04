function [] = ground_truth_comparison(Config, mriSegmented)
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
MRI_PATH = [SCI_DATA_PATH '\T1\patient\IM-0001-0001.dcm'];
const_conductivity;

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip);
ft_defaults

check_required_field(Config, 'output');
[~, imgPath] = create_output_folder(Config.output);

check_required_field(Config, 'mriSegmented');
check_required_field(Config.mriSegmented, 'method');
check_required_field(Config.mriSegmented, 'nLayers');

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load Segmented MRI
if isstring(mriSegmented)
    [~,~,ext] = fileparts(mriSegmented);
    if ext == ".mat"
        mriSegmented = load_var_from_mat('mriSegmented', mriSegmented);
    elseif ext == ".nii" || ext == ".dcm" || ext == ".IMA"
        mriSegmented = ft_read_mri(mriSegmented);
    else
        error("Unsupported filetype of segmented MRI.")
    end
end

%% Load Original MRI
mriOriginal = ft_read_mri(MRI_PATH);

%% Load Ground Truth
cfg = struct;
cfg.unit = mriOriginal.unit;
groundTruth = load_nrrd_mri(GT_PATH, cfg);
groundTruthAnatomy = load_nrrd_mri(GT_ANATOMY_PATH, cfg);

% TODO fix tissue labels % TODO make into function
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

%% Fix Resampling Differences
% Fix flips and permutations of axis (works for FieldTrip and MR-TIM):
if Config.mriSegmented.method == "fieldtrip"...
        || Config.mriSegmented.method == "mrtim"
mriSegmented.transform(2,:) = -mriSegmented.transform(2,:);

% Fix interpolation:
% TODO !

else % Default transformation
    warning("Segmentation methods other than FieldTrip and MR-TIM not tested. Applying default transformation to segmentation. Segmentation may not align with ground truth.")
    mriSegmented.transform(2,:) = -mriSegmented.transform(2,:);
end

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

%% Save Results
filename = [Config.output '\' Config.mriSegmented.method sprintf('%d',Config.mriSegmented.nLayers) '_result.mat'];
save(filename, 'absError', 'relError', 'segError', 'seg', 'truth', 'label', 'Config');
end

