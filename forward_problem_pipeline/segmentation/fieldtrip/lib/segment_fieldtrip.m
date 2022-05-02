function [mriSegmented, Info] = segment_fieldtrip(Config, mriPrepro, Info)
%SEGMENT_FIELDTRIP
%
% Required:
%   Config
%   mriPrepro
%
%   Config.nLayers
%   Config.outputPath
%   Config.imgPath
%
% Optional:
%   Info
%
%   Config.visualize
%

%% Config
check_required_field(Config, 'nLayers');
check_required_field(Config, 'outputPath');
check_required_field(Config, 'imgPath');
if ~isfield(Config, 'visualize')
    Config.visualize = false;
end

if ~exist('Info', 'var')
    Info = struct;
end


%%
nLayers = Config.nLayers;
cfg = struct;
if nLayers == 3
    cfg.output = {'brain',             'skull','scalp'};
elseif nLayers == 5
    cfg.output = {'csf','white','gray','skull','scalp'};
end
% cfg.brainsmooth    = 1; % from the tutorial
% cfg.scalpthreshold = 0.11;
% cfg.skullthreshold = 0.15;
% cfg.brainthreshold = 0.15;

% ! assumes 'mm', seems to work with mri in 'cm' too
Info.ft_volumesegment.cfg = cfg;
mriSegmented = ft_volumesegment(cfg, mriPrepro);

cfg = struct;
cfg.method = 'fieldtrip';
cfg.nLayers = nLayers;
mriSegmented = ensure_tissue_and_masks(cfg, mriSegmented);
save([Config.outputPath '\mri_segmented'], 'mriSegmented');

%% visualize
const_color; % init 'Color' struct
cfg = struct;
cfg.colormap = Color.map.(['fieldtrip' num2str(Config.nLayers)]); % distinct color per tissue
cfg.name = 'MRI segmented';
cfg.save = [Config.imgPath '\mri_segmented'];
cfg.visualize = Config.visualize;
plot_segmentation(cfg, mriSegmented, mriPrepro);
end
