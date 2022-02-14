%% Innit
clear variables
close all
cfg = struct;

%% Config - paths
cfg.FT_path = 'C:\Program Files\MATLAB\fieldtrip';

dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
cfg.mri_path = [dataPath '\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002\ANDROVICOVA_RENATA.MR.HEAD_VP03_GTEN.0002.0027.2018.12.12.08.59.13.218838.497729096.IMA'];
cfg.elec_template_path = [dataPath '\GSN-HydroCel-257.sfp'];

%% Config - out
% Results will be saved in 'out_path\data_name\run_name'
cfg.out_path = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\forward_problem_FT';
cfg.data_name = 'ANDROVICOVA_RENATA';
cfg.run_name = '01';

%% Config - miscellaneous
cfg.visualize = true;

%Config = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
forward_problem_FT(cfg)
