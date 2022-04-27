%% Innit
clear variables
close all
addpath_source;
cfg = struct;

%% Paths
cfg.path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];

outputPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\model_fieldtrip_test';
run = '01';
cfg.output = [outputPath '\' run];

%% Segmented MRI
dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';

% MR-TIM segmentation:
%cfg.mriSegmented.path = [dataPath '\test\mrtim\ANDROVICOVA_RENATA\01\anatomy_prepro_segment.nii'];
%cfg.mriSegmented.method = 'mrtim';
%cfg.mriSegmented.nLayers = 12; % 6 or 12
% ! TODO is MR-TIM output in norm space?

%FieldTrip segmentation:
cfg.mriSegmented.path = [dataPath '\segmentation_fieldtrip_test\03\mri_segmented.mat'];
cfg.mriSegmented.method = 'fieldtrip';
cfg.mriSegmented.nLayers = 5;
cfg.mriSegmented.norm2ind = [dataPath '\segmentation_fieldtrip_test\03\norm2ind.mat']; % TODO add support for var

%% Miscellaneous
cfg.visualize = true;

%% For manual run of parts of model_fieldtrip.m
%Config = cfg; clear cfg; % for manual run of parts of the pipeline

% Import here and skip '%% Import' in model_fieldtrip.m
% (Active folder should be 'ATiN_MIDA_Matous_project\model\fieldtrip'.)
%addpath(genpath('./'));
%addpath('..\..\..\common');

% Comment initialization of [elecTemplatePath] in model_fieldtrip.m
%elecTemplatePath = '..\data\elec_template\GSN-HydroCel-257.sfp';

%% Run
model_fieldtrip(cfg);
