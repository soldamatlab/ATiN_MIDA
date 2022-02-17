function [] = mrtim_auto(Config)
%% Import commons
%restoredefaultpath
%TODO throws "Unrecognized function or variable 'cfg_util'."
addpath('../common');

%% Innit SPM
if ~check_required_field(Config, 'spmPath'); return; end
addpath(Config.spmPath)
spm('defaults', 'FMRI');

%% Config
if ~check_required_field(Config, 'mrtimPath'); return; end
if ~check_required_field(Config, 'mriPath'); return; end

Config.methodName = 'mrtim';
[outputPath, imgPath] = get_output_path(Config);

%% Setup matlabbatch
% TODO add jobfile support
% TODO add more options
load defaults.mat matlabbatch;

matlabbatch{1}.spm.tools.spm_mrtim.run.anat_image = {Config.mriPath};
matlabbatch{1}.spm.tools.spm_mrtim.run.output_folder = {outputPath};
%matlabbatch{1}.spm.tools.spm_mrtim.run.prepro.res = 1;
%matlabbatch{1}.spm.tools.spm_mrtim.run.prepro.smooth = 1;
%matlabbatch{1}.spm.tools.spm_mrtim.run.prepro.biasreg = 0.001;
%matlabbatch{1}.spm.tools.spm_mrtim.run.prepro.biasfwhm = 30;
%matlabbatch{1}.spm.tools.spm_mrtim.run.prepro.lowint = 5;
matlabbatch{1}.spm.tools.spm_mrtim.run.tpmopt.tpmimg = {[Config.mrtimPath '\external\NET\template\tissues_MNI\eTPM12.nii,1']};
%matlabbatch{1}.spm.tools.spm_mrtim.run.tpmopt.mrf = 1;
%matlabbatch{1}.spm.tools.spm_mrtim.run.tpmopt.cleanup = 1;
%matlabbatch{1}.spm.tools.spm_mrtim.run.segtiss.gapfill = 1;
%matlabbatch{1}.spm.tools.spm_mrtim.run.segtiss.tiss_mask = 1;

%% Run SPM
spm_jobman('run', matlabbatch);

%% Plot output
% TODO, use 'imgPath'

end

