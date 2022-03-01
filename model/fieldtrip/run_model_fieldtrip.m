%% Innit
restoredefaultpath
clear variables
close all
cfg = struct;

%% Paths
cfg.path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];

outputPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\model_fieldtrip_test';
run = '01';
cfg.path.output = [outputPath '\' run];

%% Segmented MRI
dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';
cfg.mriSegmented.path = [dataPath '\test\mrtim\ANDROVICOVA_RENATA\01\anatomy_prepro_segment.nii'];
cfg.mriSegmented.method = 'mrtim';
cfg.mriSegmented.nLayers = 12;

%% Miscellaneous
cfg.visualize = true;

%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
model_fieldtrip(cfg);
