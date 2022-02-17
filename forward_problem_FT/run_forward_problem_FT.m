%% Innit
clear variables
close all
cfg = struct;

%% Config - paths
cfg.ftPath = [matlabroot '\toolbox\fieldtrip'];

dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
mri = '\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002\ANDROVICOVA_RENATA.MR.HEAD_VP03_GTEN.0002.0027.2018.12.12.08.59.13.218838.497729096.IMA';
cfg.mriPath = [dataPath mri];
cfg.elecTemplatePath = [dataPath '\GSN-HydroCel-257.sfp'];

%% Config - out
% Results will be saved in 'resultsPath\analysisName\dataName\runName'
cfg.resultsPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';
cfg.analysisName = 'test';
cfg.dataName = 'ANDROVICOVA_RENATA';
cfg.runName = '01';

%% Config - miscellaneous
cfg.visualize = true;

%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
forward_problem_FT(cfg)
