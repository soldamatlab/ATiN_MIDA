%% Init
clear variables
close all

%% Choose Segmented MRI
dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';
%runPath = 'segmentation_fieldtrip_test\03'; % FT 5
runPath = 'pipeline_test\ANDROVICOVA_RENATA\03\segmentation\mrtim'; % MRTIM 12
filename = 'mri_segmented.mat';

mriPath = [dataPath '\' runPath '\' filename];
clear dataPath runPath filename
Config = struct;
Config.method = 'mrtim';
Config.nLayers = 12;

%% White-to-Gray Ratio
wgRatio = get_wg_ratio(Config, mriPath);

%% Print Results
fprintf("Segmentation method: %s\n", Config.method)
fprintf("number of layers:    %d\n", Config.nLayers)
fprintf("______________________________\n")
fprintf("White-to-Gray ratio: %f\n", wgRatio)
