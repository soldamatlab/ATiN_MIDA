function [groundTruth, groundTruthPrepro] = load_ground_truth(Config)
%% Config
const_path; % init 'Path' struct
const_color; % init 'Color' struct

save = isfield(Config, 'save');
visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Load Ground Truth
cfg = struct;
cfg.unit = 'mm';
groundTruth = load_nrrd_mri(Path.data.sci.segmentation, cfg);
groundTruthPrepro = load_nrrd_mri(Path.data.sci.prepro, cfg);

cfg = struct;
cfg.method = 'SCI';
groundTruth = ensure_tissue_and_masks(cfg, groundTruth);

%% Visualize Ground Truth
if ~visualize && ~save
    return
end

cfg = struct;
cfg.colormap = Color.map.sci8; % TODO better colors
cfg.name = 'Ground Truth';
if save
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

