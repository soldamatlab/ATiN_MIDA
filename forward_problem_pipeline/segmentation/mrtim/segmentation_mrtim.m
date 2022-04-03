function [] = segmentation_mrtim(Config)
%SEGMENTATION_MRTIM TODO description
%   TODO
%
%   ! Calling 'restoredefaultpath' before this function will result in
%   "Unrecognized function or variable 'cfg_util'." error.

%% Import source code
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath([wd '\..\..\..\common']);

%% Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'spm');
check_required_field(Config.path, 'mrtim');
check_required_field(Config, 'output');
Config = set_nlayers(Config);

if isfield(Config, 'batch')
    load(Config.batch, 'matlabbatch');
    Config = set_mri_path(Config, matlabbatch);
else
    Config = set_mri_path(Config);
end

[outputPath, imgPath] = create_output_folder(Config.output);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

Config.segmentation = 'mrtim';
save([outputPath '\config'], 'Config');

%% Innit SPM
addpath(Config.path.spm)
spm('defaults', 'FMRI');

%% Setup matlabbatch
if isfield(Config, 'batch')
    matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image = {Config.mri};
    matlabbatch{1}.spm.tools.spm_mrtim.run.output_folder = {outputPath};
else
    if isfield(Config, 'mrtim')
        Mrtim = fill_mrtim_defaults(Config.mrtim, Config.path.mrtim, Config.nLayers);
    else
        Mrtim = mrtim_defaults(Config.path.mrtim, Config.nLayers);
    end
    Mrtim.run.anat_image = {Config.mri};
    Mrtim.run.output_folder = {outputPath};
    matlabbatch{1}.spm.tools.spm_mrtim = Mrtim;
end

%% Run SPM
spm_jobman('run', matlabbatch);

%% Create segmented MRI with segmentation masks
mriSegmented = ft_read_mri([outputPath '\anatomy_prepro_segment.nii']);
mriSegmented = add_segmentation_masks(mriSegmented, Config.nLayers);

%% Plot images and save additional files
save([outputPath '\mri_segmented'], 'mriSegmented');

cfg.outputPath = outputPath;
cfg.maskedMri = mriSegmented;
cfg.imgPath = imgPath;
cfg.visualize = visualize;
mrtim_plot_output(cfg);
end
