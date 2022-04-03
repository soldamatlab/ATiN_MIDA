function [mriSegmented] = segmentation_fieldtrip(Config)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath([wd '\..\..\..\common']);

%% Innit FieldTrip
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip)
ft_defaults

%% Check Config
check_required_field(Config, 'mri');
check_required_field(Config, 'output');
[outputPath, imgPath] = create_output_folder(Config.output);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

Config.segmentation = 'FieldTrip';
save([outputPath '\config'],'Config');
%% Read MRI
mriOriginal = ft_read_mri(Config.mri);
mriOriginal.coordsys = 'acpc';
save([outputPath '\mri_original'],'mriOriginal');

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
cfg.method = 'flip';
%cfg.method = 'linear';
cfg.dim    = [256 350 350];
mriPrepro = ft_volumereslice(cfg, mriOriginal);
mriPrepro = ft_convert_units(mriPrepro,'mm');

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mriPrepro);
set(fig, 'Name', 'MRI resliced')
print([imgPath '\mri_resliced'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Bias Field Correction
cfg = struct;
cfg.spmversion = 'spm12';

% SPM12 options (with FT defaults):
%opts = struct;
%opts.tpm      = fullfile(spm('dir'),'tpm','TPM.nii'); % path to tpm as nii file
%opts.biasreg  = 0.0001;
%opts.biasfwhm = 60;
%opts.lkp      = [1 1 2 2 3 3 4 4 4 5 5 5 5 6 6 ];
%opts.reg      = [0 0.001 0.5 0.05 0.2];
%opts.samp     = 3;
%opts.fwhm     = 1;
%cfg.opts = opts;

mriPrepro = ft_volumebiascorrect(cfg, mriPrepro);
save([outputPath '\mri_prepro'],'mriPrepro');

%% visualize
cfg = struct;
cfg.location = 'center';
fig = figure;
ft_sourceplot(cfg, mriPrepro);
set(fig, 'Name', 'MRI bias-corrected')
print([imgPath '\mri_bfc'],'-dpng','-r300')
if ~visualize
    close(fig)
end

%% Normalise MRI
% to get transformation matrix from individual to normalized space
cfg = struct;
cfg.nonlinear = 'no';
cfg.spmversion = 'spm12';
mriNormalised = ft_volumenormalise(cfg, mriPrepro);
save([outputPath '\mri_normalised'],'mriNormalised');

%ind2norm = mriNormalised.params.Affine; % same as 'mriNormalised.cfg.spmparams.Affine'
ind2norm = mriNormalised.initial;
norm2ind = ind2norm^-1;
save([outputPath '\norm2ind'],'norm2ind');

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
mriSegmented = ft_volumesegment(cfg, mriPrepro);
save([outputPath '\mri_segmented'],'mriSegmented');

%% visualize
seg_i = ft_datatype_segmentation(mriSegmentedFT, 'segmentationstyle', 'indexed');
%%
cfg              = struct;
cfg.funparameter = 'tissue';
cfg.funcolormap  = lines(6); % distinct color per tissue
cfg.location     = 'center';
% cfg.atlas        = seg_i;    % the segmentation can also be used as atlas
fig = figure;
ft_sourceplot(cfg, seg_i, mriPrepro);
set(fig, 'Name', 'MRI segmented')
print([imgPath '\mri_segmented'],'-dpng','-r300')
if ~visualize
    close(fig)
end
end
