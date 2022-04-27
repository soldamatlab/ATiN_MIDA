%% Innit
clear variables
close all
addpath_source;
cfg = struct;

%% Paths
outputPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\segmentation_fieldtrip_test';
run = '01';
cfg.output = [outputPath '\' run];

dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
mri = '\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002\ANDROVICOVA_RENATA.MR.HEAD_VP03_GTEN.0002.0001.2018.12.12.08.59.13.218838.497728628.IMA';
cfg.mri = [dataPath mri];

cfg.nLayers = 5; % 3 or 5 or [3 5] for both

%% Miscellaneous
cfg.visualize = true;

%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
mriSegmented = segmentation_fieldtrip(cfg);
