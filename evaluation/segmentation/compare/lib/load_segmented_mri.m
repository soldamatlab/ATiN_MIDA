function [mriSegmented, mriPrepro] = load_segmented_mri(Config)
% LOAD_SEGMENTED_MRI
%   Required:
%   Config.prepro
%   Config.segmentation
%   Config.method
%   Config.nLayers
%
%   Optional:
%   Config.visualize
%   Config.save
%   Config.colormap
%   Config.name

%% Config
check_required_field(Config, 'prepro');
check_required_field(Config, 'segmentation');
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end
save = isfield(Config, 'save');

%% Load MRIs
mriSegmented = load_mri_anytype(Config.segmentation, 'mriSegmented');
mriPrepro = load_mri_anytype(Config.prepro, 'mriPrepro');

cfg = struct;
cfg.method = Config.method;
cfg.nLayers = Config.nLayers;
mriSegmented = ensure_tissue_and_masks(cfg, mriSegmented);

%% Visualize Segmented MRI
if ~visualize && ~save
    return
end

cfg = struct;
if isfield(Config, 'name')
    cfg.name = Config.name;
else
    cfg.name = 'Segmented MRI';
end
if isfield(Config, 'colormap')
    cfg.colormap = Config.colormap;
end
if save
    cfg.save = Config.save;
end
cfg.visualize = visualize;
plot_segmentation(cfg, mriSegmented, mriPrepro);
end
