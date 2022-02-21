function [] = mrtim_auto(Config)
%MRTIM_AUTO TODO description
%   TODO

%% Import source code
%TODO throws "Unrecognized function or variable 'cfg_util'."
%restoredefaultpath
addpath(genpath('./'));
addpath('../common');

%% Check Config
check_required_field(Config, 'spmPath');
check_required_field(Config, 'mrtimPath');
if isfield(Config, 'batch')
    load(Config.batch, 'matlabbatch');
    Config = set_mri_path(Config, matlabbatch);
else
    Config = set_mri_path(Config);
end
Config.methodName = 'mrtim';
[outputPath, imgPath] = get_output_path(Config);

%% Innit SPM
addpath(Config.spmPath)
spm('defaults', 'FMRI');

%% Setup matlabbatch
if isfield(Config, 'batch')
    matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image = {Config.mriPath};
    matlabbatch{1}.spm.tools.spm_mrtim.run.output_folder = {outputPath};
else
    if isfield(Config, 'mrtim')
        Mrtim = fill_mrtim_defaults(Config.mrtim, Config.mrtimPath);
    else
        Mrtim = mrtim_defaults(Config.mrtimPath);
    end
    Mrtim.run.anat_image = {Config.mriPath};
    Mrtim.run.output_folder = {outputPath};
    matlabbatch{1}.spm.tools.spm_mrtim = Mrtim;
end

%% Run SPM
spm_jobman('run', matlabbatch);

%% Plot images from output
mrtim_plot_output(outputPath, imgPath);

end

