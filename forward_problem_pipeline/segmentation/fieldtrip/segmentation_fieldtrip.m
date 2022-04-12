function [mriSegmented] = segmentation_fieldtrip(Config)
%% SEGMENTATION_FIELDTRIP
%
% Config:
% Config.coordsys   - if set will overwrite mri.coordsys with given value
%
% TODO

%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath(genpath([wd '\..\..\..\common']));

%% Innit FieldTrip
check_required_field(Config, 'path');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip)
ft_defaults

%% Check Config
check_required_field(Config, 'mri');
check_required_field(Config, 'output');
[outputPath, imgPath] = create_output_folder(Config.output);

SUPPORTED_NLAYERS = [3, 5];
DEFAULT_NLAYERS = 5;
if isfield(Config, 'nLayers')
    if ~ismember(Config.nLayers, SUPPORTED_NLAYERS)
        error("%d-layer segmentation not supported. Choose from 3 and 5.", Config.nLayers)
    end
else
    Config.nLayers = DEFAULT_NLAYERS;
    warning("[nLayers] not set. Using default number of layers (%d).", DEFAULT_NLAYERS)
end

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

Config.method = 'fieldtrip';
save([outputPath '\config'],'Config');
Info = struct;
%% Read MRI
mriOriginal = ft_read_mri(Config.mri);
if isfield(Config, 'coordsys')
    mriOriginal.coordsys = Config.coordsys;
end
if mriOriginal.coordsys == "scanras" % FT throws errors with scanras
    mriOriginal.coordsys = 'acpc';
    warning("Replacing MRI.coordsys 'scanras' with 'acpc'.")
end
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
cfg.method = 'linear';
cfg.dim    = [256 350 350];
Info.ft_volumereslice.cfg = cfg;
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

Info.ft_volumebiascorrect.cfg = cfg;
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
Info.ft_volumenormalise.cfg = cfg;
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
if Config.nLayers == 3
    cfg.output = {'brain',             'skull','scalp'};
elseif Config.nLayers == 5
    cfg.output = {'csf','white','gray','skull','scalp'};
end
% cfg.brainsmooth    = 1; % from the tutorial
% cfg.scalpthreshold = 0.11;
% cfg.skullthreshold = 0.15;
% cfg.brainthreshold = 0.15;

% ! assumes 'mm', seems to work with mri in 'cm' too
Info.ft_volumesegment.cfg = cfg;
mriSegmented = ft_volumesegment(cfg, mriPrepro);
mriSegmented = ensure_tissue_and_masks(Config, mriSegmented);
save([outputPath '\mri_segmented'],'mriSegmented');

%% visualize
cfg = struct;
cfg.colormap = lines(Config.nLayers + 1); % distinct color per tissue
cfg.name = 'MRI segmented';
cfg.save = [imgPath '\mri_segmented'];
cfg.visualize = visualize;
plot_segmentation(cfg, mriSegmented, mriPrepro);

%% Save Info
save([outputPath '\info'],'Info');
end
