function [] = mrtim_auto(Config)
%% Import commons
%TODO throws "Unrecognized function or variable 'cfg_util'."
%restoredefaultpath
addpath('../common');

%% Check Config
check_paths(Config);
Config.methodName = 'mrtim';
[outputPath, imgPath] = get_output_path(Config);

%% Innit SPM
addpath(Config.spmPath)
spm('defaults', 'FMRI');

%% Setup matlabbatch
% TODO add jobfile support
if isfield(Config, 'mrtim')
    Mrtim = fill_mrtim_defaults(Config.mrtim, Config.mrtimPath);
else
    Mrtim = mrtim_defaults(Config.mrtimPath);
end
Mrtim.run.anat_image = {Config.mriPath};
Mrtim.run.output_folder = {outputPath};
matlabbatch{1}.spm.tools.spm_mrtim = Mrtim;

%% Run SPM
spm_jobman('run', matlabbatch);

%% Plot images from output
mrtim_plot_output(outputPath, imgPath);

end

