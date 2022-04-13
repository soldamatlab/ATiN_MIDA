function [groundTruth, groundTruthPrepro] = load_ground_truth(Config)
%% Config
wd = fileparts(mfilename('fullpath'));
SCI_DATA_PATH = [wd '\..\..\..\..\data\SCI'];
GT_PATH = [SCI_DATA_PATH '\Segmentation\HeadSegmentation.nrrd'];
GT_PREPRO_PATH = [SCI_DATA_PATH '\T1\T1_Corrected.nrrd'];

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load Ground Truth
cfg = struct;
cfg.unit = 'mm';
groundTruth = load_nrrd_mri(GT_PATH, cfg);
groundTruthPrepro = load_nrrd_mri(GT_PREPRO_PATH, cfg);

cfg = struct;
cfg.method = 'SCI';
groundTruth = ensure_tissue_and_masks(cfg, groundTruth);

%% Visualize Ground Truth
cfg = struct;
cfg.colormap = [white(1); lines(7); spring(1)]; % TODO better colors
cfg.name = 'Ground Truth';
if isfield(Config, 'save')
    cfg.save = Config.save;
end
cfg.visualize = visualize;
plot_segmentation(cfg, groundTruth, groundTruthPrepro);

%% Visualize Ground Truth Masks % TODO
%tissue = SCI_LABEL{1};
%cfg = struct;
%cfg.name = tissue;
%cfg.parameter = tissue;
%fig = plot_mask(cfg, groundTruth);
end

