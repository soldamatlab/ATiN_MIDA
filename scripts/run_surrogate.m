%% Init
clear variables
close all
addpath_source;

%% Config
cfg = struct;

% choose one or more from 'SUPPORTED_METHODS' in surrogate.m
cfg.method = "eloreta";
cfg.snr = [5, 25];
cfg.dipoleDownsample = 512; % 1 for no downsample, 'x' for every 'x'th dipole

cfg.modelPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\model_fieldtrip_test\03'; % TODO

%% Run
[evaluation, evaluationTable] = surrogate(cfg);
