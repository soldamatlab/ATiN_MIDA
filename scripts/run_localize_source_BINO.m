%% Init
clear variables
close all
addpath_source;

%% Paths
dataPath = '\\Pc-matous\bp_mida\data\BINO\EEG\bino-001_20191014_133201_cut.mat'; % PC-MATOUS remote
modelPath = '\\Pc-matous\bp_mida\analysis\BINO\S1\segmentation\mrtim12'; % PC-MATOUS remote

%% Load EEG data
load(dataPath); % loads 'data' and 'events' variables

%% Load model
sourcemodel = load_var_from_mat('sourcemodel', [modelPath '\sourcemodel.mat']);
headmodel = load_var_from_mat('headmodel', [modelPath '\headmodel.mat']);

%% Config
cfg = struct;
cfg.output = '';

cfg.sourcemodel = sourcemodel;
cfg.headmodel = headmodel;

cfg.channel = 1:256;
cfg.rereference = 'avg';

%% Run
localize_source(cfg, data, events);
