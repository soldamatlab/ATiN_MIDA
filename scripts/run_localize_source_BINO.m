%% Init
clear variables
close all
addpath_source;

%% Paths
root = '\\Pc-matous\bp_mida';  % PC-MATOUS remote
dataPath = [root '\data\BINO\EEG\bino-001_20191014_133201_cut.mat'];
subjectPath = [root '\analysis\BINO\S1'];
segMethod = 'mrtim12';

modelPath = [subjectPath '\model\' segMethod];
if contains(segMethod, 'mrtim')
    mriPreproPath = [subjectPath '\segmentation\' segMethod '\anatomy_prepro.nii'];
else
    mriPreproPath = [subjectPath '\segmentation\' segMethod '\mri_prepro.mat'];
end

%% Load EEG data
load(dataPath); % loads 'data' and 'events' variables

%% Load model
sourcemodel = load_var_from_mat('sourcemodel', [modelPath '\sourcemodel.mat']);
headmodel = load_var_from_mat('headmodel', [modelPath '\headmodel.mat']);
mriPrepro = load_mri_anytype(mriPreproPath, 'mriPrepro');

%% Config
cfg = struct;
cfg.output = [modelPath '\..\..\evaluation\stimulate'];

cfg.sourcemodel = sourcemodel;
cfg.headmodel = headmodel;
cfg.mri = mriPrepro;

cfg.channel = 1:256;
cfg.rereference = 'avg';

%% Run
localize_source(cfg, data, events);
