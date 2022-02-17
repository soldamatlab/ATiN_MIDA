%% Innit
clear variables
close all
cfg = struct;

%% Config - paths
cfg.spmPath = [matlabroot '\toolbox\spm12'];
cfg.mrtimPath = 'C:\Program Files\MATLAB\R2021a\toolbox\spm12\toolbox\MRTIM';

dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
mri = '\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002\T1_SAG_MPR_3D_1MM_ISO_P2_0002_t1_sag_mpr_3D_1mm_ISO_p2_20181204120528_2.nii,1';
cfg.mriPath = [dataPath mri];

%% Config - out
% Results will be saved in 'resultsPath\analysisName\dataName\runName'
cfg.resultsPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';
cfg.analysisName = 'test';
cfg.dataName = 'ANDROVICOVA_RENATA';
cfg.runName = '01';

%% Config - miscellaneous
%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
mrtim_auto(cfg);
