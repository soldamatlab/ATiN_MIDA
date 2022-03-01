function [mriSegmented] = segmentation_fieldtrip(Config)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath([wd '\..\..\common']);

%% Innit FieldTrip
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip)
ft_defaults

%% Config
check_required_field(Config, 'mri');
check_required_field(Config.path, 'output');
[outputPath, imgPath] = create_output_folder(Config.path.output);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

Config.segmentation = 'FieldTrip';

%% 1 Read the MRI
mri = ft_read_mri(Config.mri);

%% visualize
cfg = struct;
%cfg.funparameter = 'anatomy';
%cfg.colormap = spring;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mri);
set(fig, 'Name', 'MRI original')
print([imgPath '\mri_original'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% (5) Realign the MRI
% ! electrodes are realigned to individual space instead
% cfg = struct;
% cfg.method = 'interactive';
% cfg.coordsys = 'acpc';
% mri = ft_volumerealign(cfg, mri);

%% visualize
% if visualize
%     cfg = struct;
%     cfg.location = 'center';
%     figure()
%     ft_sourceplot(cfg, mri);
% end

%% 2 Reslice the MRI
cfg = struct;
cfg.method = 'linear';
cfg.dim    = [256 350 350];
mri = ft_volumereslice(cfg, mri);
mri = ft_convert_units(mri,'mm');

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mri);
set(fig, 'Name', 'MRI resliced')
print([imgPath '\mri_resliced'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% FEM
%% 3(FEM) Segment the MRI
mri.coordsys = 'acpc';
cfg = struct;
cfg.output         = {'scalp','skull','csf','gray','white'};
% cfg.brainsmooth    = 1; % from the tutorial
% cfg.scalpthreshold = 0.11;
% cfg.skullthreshold = 0.15;
% cfg.brainthreshold = 0.15;

% ! assumes 'mm', seems to work with mri in 'cm' too
mriSegmented = ft_volumesegment(cfg, mri);

%% visualize
seg_i = ft_datatype_segmentation(mriSegmented, 'segmentationstyle', 'indexed');

cfg              = struct;
cfg.funparameter = 'tissue';
cfg.funcolormap  = lines(6); % distinct color per tissue
cfg.location     = 'center';
% cfg.atlas        = seg_i;    % the segmentation can also be used as atlas
fig = figure;
ft_sourceplot(cfg, seg_i, mri);
set(fig, 'Name', 'MRI segmented')
print([imgPath '\mri_segmented'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Save data
save([outputPath '\mri'],'mri');
save([outputPath '\mri_segmented'],'mriSegmented');

save([outputPath '\config'],'Config');
end
