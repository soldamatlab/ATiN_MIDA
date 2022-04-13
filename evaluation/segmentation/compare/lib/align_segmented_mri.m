function [mriPrepro, mriSegmented] = align_segmented_mri(Config)
% ALIGN_SEGMENTED_MRI
%   Required:
%   Config.seg - struct, see below
%   Config.seg.prepro
%
%   Config.target - struct, see below
%   Config.target.prepro
%
%   Optional:
%   Config.seg.segmentation
%   Config.target.method
%
%   Config.visualize
%   Config.save
%   Config.colormap
%   Config.name

%% Config
check_required_field(Config, 'seg');
check_required_field(Config.seg, 'prepro');
check_required_field(Config, 'target');
check_required_field(Config.target, 'prepro');

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end
save = isfield(Config, 'save');
%% Align
mriPrepro = Config.seg.prepro;
target = Config.target.prepro;

if isfield(Config.target, 'method')
    if strcmp(Config.target.method, "SCI")
        mriPrepro.transform(2,:) = -mriPrepro.transform(2,:);
    end
end

cfg = struct;
cfg.method = 'spm';
mriPrepro = ft_volumerealign(cfg, mriPrepro, target);

if ~isfield(Config.seg, 'segmentation')
    return
end
mriSegmented = Config.seg.segmentation;
mriSegmented.transform = mriPrepro.transform;

%% Visualize Segmented MRI
if ~visualize && ~save
    return
end

cfg = struct;
if isfield(Config, 'name')
    cfg.name = Config.name;
else
    cfg.name = 'Aligned Segmentation';
end
if isfield(Config, 'colormap')
    cfg.colormap = Config.colormap;
end
if save
    cfg.save = Config.save;
end
cfg.visualize = visualize;
plot_segmentation(cfg, mriSegmented, target);
end

