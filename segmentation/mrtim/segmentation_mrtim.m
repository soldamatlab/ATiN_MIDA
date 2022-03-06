function [] = segmentation_mrtim(Config)
%SEGMENTATION_MRTIM TODO description
%   TODO
%
%   ! Calling 'restoredefaultpath' before this function will result in
%   "Unrecognized function or variable 'cfg_util'." error.

%% Import source code
wd = fileparts(mfilename('fullpath'));
addpath(genpath(wd));
addpath([wd '/../../common']);

%% Check Config
check_required_field(Config, 'path');
check_required_field(Config.path, 'spm');
check_required_field(Config.path, 'mrtim');
check_required_field(Config.path, 'output');

if isfield(Config, 'batch')
    load(Config.batch, 'matlabbatch');
    Config = set_mri_path(Config, matlabbatch);
else
    Config = set_mri_path(Config);
end

[outputPath, imgPath] = create_output_folder(Config.path.output);

visualize = false;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

Config.segmentation = 'mrtim';

%% Innit SPM
addpath(Config.path.spm)
spm('defaults', 'FMRI');

%% Setup matlabbatch
if isfield(Config, 'batch')
    matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image = {Config.mri};
    matlabbatch{1}.spm.tools.spm_mrtim.run.output_folder = {outputPath};
else
    if isfield(Config, 'mrtim')
        Mrtim = fill_mrtim_defaults(Config.mrtim, Config.path.mrtim);
    else
        Mrtim = mrtim_defaults(Config.path.mrtim);
    end
    Mrtim.run.anat_image = {Config.mri};
    Mrtim.run.output_folder = {outputPath};
    matlabbatch{1}.spm.tools.spm_mrtim = Mrtim;
end

%% Run SPM
spm_jobman('run', matlabbatch);

%% Create segmented MRI with segmentation masks
mriSegmented = ft_read_mri([outputPath '\anatomy_prepro_segment.nii']);
mriSegmented = mrtim_add_segmentation_masks(mriSegmented, 12); % TODO implement 6 layers

%% Plot images and save additional files
save([outputPath '\config'], 'Config');
save([outputPath '\mri_segmented'], 'mriSegmented');

cfg.outputPath = outputPath;
cfg.maskedMri = mriSegmented;
cfg.imgPath = imgPath;
cfg.visualize = visualize;
mrtim_plot_output(cfg);
end
