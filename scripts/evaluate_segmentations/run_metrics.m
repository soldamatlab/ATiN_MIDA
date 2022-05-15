%% Init
clear variables
close all
addpath_source

%% Choose Segmented MRI
dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';
%runPath = 'segmentation_fieldtrip_test\03'; % FT 5
runPath = 'pipeline_test\ANDROVICOVA_RENATA\03\segmentation\mrtim'; % MRTIM 12
filename = 'mri_segmented.mat';
mriPath = [dataPath '\' runPath '\' filename];
clear dataPath runPath filename

Config = struct;
Config.method = 'mrtim'; % 'fieldtrip'
Config.nLayers = 12; % 5

%% Gray-to-White Ratio
if Config.method == "mrtim" && Config.nLayers == 12
    [GWR, GWRb, GWRc] = get_gray_white_ratio(Config, mriPath);
else
    GWR = get_gray_white_ratio(Config, mriPath);
end

%% Print Results
fprintf("Segmentation method: %s\n", Config.method)
fprintf("Number of layers:    %d\n", Config.nLayers)
fprintf("______________________________\n")
fprintf("GWR:                 %f\n", GWR)
if Config.method == "mrtim" && Config.nLayers == 12
    fprintf("GWR brain:           %f\n", GWRb)
    fprintf("GWR cerebrum:        %f\n", GWRc)
end
