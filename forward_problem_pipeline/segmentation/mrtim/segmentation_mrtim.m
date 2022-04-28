function [mriSegmented] = segmentation_mrtim(Config)
%SEGMENTATION_MRTIM TODO description
%addpath_source has to be called first.
%
%   Required:
%   TODO
%
%   Optional:
%   Config.nLayers
%   Config.allowExistingFolder = logcial, default false, setting to true
%                                enables saving output in an already
%                                existing folder
%   Config.fillBatch = logical, default true, if set to false Config.batch
%                      will be used as is with no changes
%   TODO
%
%   ! Calling 'restoredefaultpath' before this function will result in
%   "Unrecognized function or variable 'cfg_util'." error.

%% Innit
addpath_source;
spm('defaults', 'FMRI');

%% Config
Config = set_nlayers(Config);

if isfield(Config, 'batch')
    Config = set_batch(Config);
    Config = set_mri_path(Config, Config.batch);
else
    Config = set_mri_path(Config);
end
if ~isfield(Config, 'fillBatch')
    Config.fillBatch = true;
end

if Config.fillBatch
    Config.output = [Config.output '\mrtim' num2str(Config.nLayers)];
else
    Config.output = Config.batch{1, 1}.spm.tools.spm_mrtim.run.output_folder{1, 1};
end
check_required_field(Config, 'output');
if ~isfield(Config, 'allowExistingFolder')
    Config.allowExistingFolder = false;
end
[Config.output, imgPath] = create_output_folder(Config.output, Config.allowExistingFolder);

if ~isfield(Config, 'visualize')
    Config.visualize = false;
end
visualize = Config.visualize;

Config.method = 'mrtim';
save([Config.output '\config'], 'Config');

%% Run SPM
matlabbatch = get_batch(Config);
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
