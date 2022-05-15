%% Innit
% ! DO NOT restoredefaultpath !
% MR-TIM throws "Unrecognized function or variable 'cfg_util'."
clear variables
close all
addpath_source;
const_path; % init 'Path' structure
cfg = struct;

%% Simple call
cfg.path.mrtim = Path.toolbox.mrtim;
cfg.mri = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data\BINO\Structural\S1\0003_t1_sag_mpr_3D_v01.nii';
cfg.output = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\analysis\BINO\S1\segmentation';

%% MR-TIM Settings
% See 'mrtim_defaults' or MR-TIM manual for all options
%cfg.mrtim.run.prepro.res = 1;

%% MR-TIM Setting via Matlabbatch
% path to matlabbatch in a '.mat' file
%cfg.batch = './matlabbatch\example_batch.mat'; 

% or matlabbatch as var
%cfg.batch = matlabbatch;

%cfg.fillBatch = false; % set false to use batch as is with no changes

%% Miscellaneous
cfg.visualize = true;
%cfg.allowExistingFolder = true;

%cfg = cfg; clear cfg; % for manual run of parts of the pipeline

%% Run
mriSegmented = segmentation_mrtim(cfg);
