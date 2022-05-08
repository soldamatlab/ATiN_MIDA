%% Init
clear variables
close all
addpath_source;

%% Config
cfg = struct;

% choose one or more from 'SUPPORTED_METHODS' in surrogate.m
cfg.method = 'eloreta';
cfg.signal.snr = 10;
cfg.dipoleDownsample = 1; % 1 for no downsample, 'x' for every 'x'th dipole

cfg.modelPath = '\S:\BP_MIDA\analysis\BINO\S1\model\mrtim12';
cfg.output = [cfg.modelPath '\..\..\evaluation\surrogate'];

%% Run
[evaluation, evaluationTable] = surrogate(cfg);
