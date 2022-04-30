%% Innit
clear variables
close all
addpath_source;
cfg = struct;

%% Paths
outputPath = 'S:\BP_MIDA\test\model_fieldtrip';
run = '01';
cfg.output = [outputPath '\' run];

%% Model one segmentation
segmentationPath = 'S:\BP_MIDA\analysis\NUDZ\ANDROVICOVA_RENATA_8753138768\segmentation\fieldtrip5';
cfg.mriSegmented.path = [segmentationPath '\mri_segmented.mat'];
cfg.mriSegmented.method = 'fieldtrip';                  % 'fieldtrip', 'mrtim'
cfg.mriSegmented.nLayers = 5;                           % 3, 5, 12
cfg.mriSegmented.norm2ind = [segmentationPath '\norm2ind.mat'];

%% Model more segmentations and match dipole positions of sourcemodels
segmentationPath1 = 'S:\BP_MIDA\analysis\NUDZ\ANDROVICOVA_RENATA_8753138768\segmentation\fieldtrip5_anatomy_prepro';
path1 = [segmentationPath1 '\mri_segmented.mat'];
method1 = 'fieldtrip';
nLayers1 = 5;
suffix1 = 'anatomy_prepro';

segmentationPath2 = 'S:\BP_MIDA\analysis\NUDZ\ANDROVICOVA_RENATA_8753138768\segmentation\mrtim12';
path2 = [segmentationPath2 '\mri_segmented.mat'];
method2 = 'mrtim';
nLayers2 = 12;

cfg.mriSegmented.path = {path1, path2};
cfg.mriSegmented.method = {method1, method2};
cfg.mriSegmented.nLayers = [nLayers1, nLayers2];
%cfg.mriSegmented.norm2ind = {norm2ind1, norm2ind2};
cfg.suffix = {suffix1, ''};
cfg.sourcemodel = 'matchpos';

%% Options
cfg.visualize = true;

%% For manual run of parts of model_fieldtrip.m
%Config = cfg; clear cfg;

%% Run
model_fieldtrip(cfg);
