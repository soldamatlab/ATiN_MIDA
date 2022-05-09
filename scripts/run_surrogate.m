%% Init
clear variables
close all
addpath_source;

%% Config
cfg = struct;

% choose one or more from 'SUPPORTED_METHODS' in surrogate.m
cfg.method = 'eloreta';
cfg.signal.snr = 10;
cfg.dipoleDownsample = 2; % 1 for no downsample, 'x' for every 'x'th dipole

cfg.modelPath = '\\Pc-matous\BP_MIDA\analysis\BINO\S1\model\mrtim12';
cfg.mri = '\\Pc-matous\BP_MIDA\analysis\BINO\S1\segmentation\mrtim12\anatomy_prepro.nii';
cfg.output = [cfg.modelPath '\..\..\evaluation\surrogate2'];

%% Run
[evaluation, evaluationTable] = surrogate(cfg);
