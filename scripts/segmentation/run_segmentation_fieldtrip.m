%% Innit
clear variables
close all
addpath_source;
cfg = struct;

%% Paths
%cfg.mri = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data\BINO\Structural\S1\0003_t1_sag_mpr_3D_v01\MR.1.3.12.2.1107.5.2.43.66063.2015121708585823020301817.IMA';

cfg.mriPrepro = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\analysis\BINO\S1\segmentation\mrtim12\anatomy_prepro.nii';
cfg.suffix = 'anatomy_prepro';

cfg.output = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\analysis\BINO\S1\segmentation';
cfg.nLayers = 5; % 3 or 5 or [3 5] for both
cfg.coordsys = 'acpc';

%% Miscellaneous
cfg.visualize = true;

%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
mriSegmented = segmentation_fieldtrip(cfg);
