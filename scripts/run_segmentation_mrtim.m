%% Innit
%restoredefaultpath % TODO throws "Unrecognized function or variable 'cfg_util'."
clear variables
close all
addpath_source
cfg = struct;

%% Paths
cfg.path.spm = [matlabroot '\toolbox\spm12'];
cfg.path.mrtim = [matlabroot '\toolbox\spm12\toolbox\MRTIM'];
cfg.path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];

outputPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\segmentation_mrtim_test';
run = '01';
cfg.output = [outputPath '\' run];

dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
mri = '\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002\T1_SAG_MPR_3D_1MM_ISO_P2_0002_t1_sag_mpr_3D_1mm_ISO_p2_20181204120528_2.nii';
cfg.mri = [dataPath mri];

%% MR-TIM Settings
% See 'mrtim_defaults' or MR-TIM manual for all options
%cfg.mrtim.run.prepro.res = 1;

%% MR-TIM Setting via Matlabbatch
%cfg.batch = './matlabbatch\example_batch.mat';

%% Miscellaneous
%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
segmentation_mrtim(cfg);
