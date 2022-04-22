function [] = segmentation_mrtim(Config)
%SEGMENTATION_MRTIM TODO description
%   Required:
%   TODO
%
%   Optional:
%   Config.nLayers
%   TODO
%
%   ! Calling 'restoredefaultpath' before this function will result in
%   "Unrecognized function or variable 'cfg_util'." error.

%% Import source code
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath(genpath([wd '\..\..\..\common']));

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'spm');
check_required_field(Config.path, 'mrtim');
check_required_field(Config.path, 'fieldtrip');
addpath(Config.path.fieldtrip)
ft_defaults

check_required_field(Config, 'output');
Config = set_nlayers(Config);

if isfield(Config, 'batch')
    load(Config.batch, 'matlabbatch');
    Config = set_mri_path(Config, matlabbatch);
else
    Config = set_mri_path(Config);
end

Config.output = [Config.output '\mrtim' num2str(Config.nLayers)];
[Config.output, imgPath] = create_output_folder(Config.output);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

Config.method = 'mrtim';
save([Config.output '\config'], 'Config');

%% Innit SPM
addpath(Config.path.spm)
spm('defaults', 'FMRI');

%% Run SPM
matlabbatch = setup_matlabbatch(Config);
spm_jobman('run', matlabbatch);

%% Create segmented MRI with segmentation masks
mriSegmented = ft_read_mri([Config.output '\anatomy_prepro_segment.nii']);
mriSegmented = ensure_tissue_and_masks(Config, mriSegmented);

%% Plot images and save additional files
save([Config.output '\mri_segmented'], 'mriSegmented');

cfg.outputPath = Config.output;
cfg.maskedMri = mriSegmented;
cfg.imgPath = imgPath;
cfg.visualize = visualize;
mrtim_plot_output(cfg);
end
