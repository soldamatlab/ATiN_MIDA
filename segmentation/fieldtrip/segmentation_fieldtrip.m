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

%% Read MRI
mriOriginal = ft_read_mri(Config.mri);
mriOriginal.coordsys = 'acpc';

%% visualize
cfg = struct;
%cfg.funparameter = 'anatomy';
%cfg.colormap = spring;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mriOriginal);
set(fig, 'Name', 'MRI original')
print([imgPath '\mri_original'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Reslice MRI
cfg = struct;
cfg.method = 'linear';
cfg.dim    = [256 350 350];
mriResliced = ft_volumereslice(cfg, mriOriginal);
mriResliced = ft_convert_units(mriResliced,'mm');

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mriResliced);
set(fig, 'Name', 'MRI resliced')
print([imgPath '\mri_resliced'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Normalise MRI
% to get transformation matrix from individual to normalized space
cfg = struct;
cfg.nonlinear = 'no';
cfg.spmversion = 'spm12';
mriNormalised = ft_volumenormalise(cfg, mriResliced);
ind2norm = mriNormalised.params.Affine; % same as 'mriNormalised.cfg.spmparams.Affine'
norm2ind = ind2norm^-1;

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mriNormalised);
set(fig, 'Name', 'MRI normalised')
print([imgPath '\mri_normalised'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% FEM
%% Segment the MRI
cfg = struct;
cfg.output         = {'scalp','skull','csf','gray','white'};
% cfg.brainsmooth    = 1; % from the tutorial
% cfg.scalpthreshold = 0.11;
% cfg.skullthreshold = 0.15;
% cfg.brainthreshold = 0.15;

% ! assumes 'mm', seems to work with mri in 'cm' too
mriSegmented = ft_volumesegment(cfg, mriResliced);

%% visualize
seg_i = ft_datatype_segmentation(mriSegmented, 'segmentationstyle', 'indexed');

cfg              = struct;
cfg.funparameter = 'tissue';
cfg.funcolormap  = lines(6); % distinct color per tissue
cfg.location     = 'center';
% cfg.atlas        = seg_i;    % the segmentation can also be used as atlas
fig = figure;
ft_sourceplot(cfg, seg_i, mriResliced);
set(fig, 'Name', 'MRI segmented')
print([imgPath '\mri_segmented'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Save data
save([outputPath '\mri_original'],'mriOriginal');
save([outputPath '\mri_resliced'],'mriResliced');
save([outputPath '\mri_normalised'],'mriNormalised');
save([outputPath '\norm2ind'],'norm2ind');
save([outputPath '\mri_segmented'],'mriSegmented');

save([outputPath '\config'],'Config');
end
