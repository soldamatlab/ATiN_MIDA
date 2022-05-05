function [mriPrepro, Info] = preprocess_fieldtrip(Config, mriOriginal, Info)
%PREPROCESS_FIELDTRIP
%
% Required:
%   Config
%   mriOriginal
%
%   Config.outputPath
%   Config.imgPath
%
% Optional:
%   Info
%
%   Config.visualize

%% Config
check_required_field(Config, 'outputPath');
check_required_field(Config, 'imgPath');
if ~isfield(Config, 'visualize')
    Config.visualize = false;
end

if ~exist('Info', 'var')
    Info = struct;
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
cfg.crosshair = 'no';
fig = figure;
ft_sourceplot(cfg, mriPrepro);
set(fig, 'Name', 'MRI resliced')
multipath_print(imgPath, 'mri_resliced');
if ~Config.visualize
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
multipath_save(outputPath, 'mri_prepro', mriPrepro, 'mriPrepro');

%% visualize
cfg = struct;
cfg.location = 'center';
cfg.crosshair = 'no';
fig = figure;
ft_sourceplot(cfg, mriPrepro);
set(fig, 'Name', 'MRI bias-corrected')
multipath_print(imgPath, 'mri_bfc');
if ~Config.visualize
    close(fig)
end

%% Normalise MRI
% to get transformation matrix from individual to normalized space
cfg = struct;
cfg.nonlinear = 'no';
cfg.spmversion = 'spm12';
Info.ft_volumenormalise.cfg = cfg;
mriNormalised = ft_volumenormalise(cfg, mriPrepro);
multipath_save(outputPath, 'mri_normalised', mriNormalised, 'mriNormalised');


%ind2norm = mriNormalised.params.Affine; % same as 'mriNormalised.cfg.spmparams.Affine'
ind2norm = mriNormalised.initial;
norm2ind = ind2norm^-1;
multipath_save(outputPath, 'norm2ind', norm2ind, 'norm2ind');


%% visualize
cfg = struct;
cfg.location = 'center';
cfg.crosshair = 'no';
fig = figure;
ft_sourceplot(cfg, mriNormalised);
set(fig, 'Name', 'MRI normalised')
multipath_print(imgPath, 'mri_normalised');
if ~Config.visualize
    close(fig)
end
end
