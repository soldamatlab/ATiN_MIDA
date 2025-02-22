%% Init
clear variables
close all
sourceRoot = addpath_source;
Info = struct;

%% Define paths
Path = struct;
% Data:
Path.data = [sourceRoot '\data'];
Path.mri = [Path.data '\SCI\T1\patient\IM-0001-0001.dcm'];
Path.mriNII = [Path.data '\SCI\T1\patient.nii'];

% Toolboxes:
Path.mrtim = [matlabroot '\toolbox\spm12\toolbox\MRTIM'];

% Output:
Path.data = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data';
Path.output = [Path.data '\analysis\SCI'];
%Path.output = [Path.data '\analysis\NUDZ\ANDROVICOVA_RENATA_8753138768'];
Path.segmentation = [Path.output '\segmentation'];
Path.segmentationFT = [Path.segmentation '\fieldtrip'];
Path.segmentationMRTIM = [Path.segmentation '\mrtim'];
Path.result = [Path.segmentation '\evaluation'];

%% Segment MRI by FieldTrip
% See 'run_segmentation_fieldtrip.m'
cfgFT = struct;
cfgFT.nLayers = 5;
cfgFT.output = [Path.segmentationFT num2str(cfgFT.nLayers)]; % output path as string
cfgFT.mri = Path.mri;
cfgFT.visualize = true;

Info.fieldtrip.method = 'fieldtrip';
Info.fieldtrip.nLayers = cfgFT.nLayers;
Info.fieldtrip.mriSegmented = [cfgFT.output '\mri_segmented.mat'];
Info.fieldtrip.mriPrepro = [cfgFT.output '\mri_prepro.mat'];
%%
mriSegmented = segmentation_fieldtrip(cfgFT);

%% Segment MRI by MR-TIM
% See 'run_segmentation_mrtim.m'
cfgMRTIM = struct;
cfgMRTIM.path.mrtim = Path.mrtim;
cfgMRTIM.nLayers = 12;
cfgMRTIM.output = [Path.segmentationMRTIM num2str(cfgMRTIM.nLayers)]; % output path as string
cfgMRTIM.mri = Path.mriNII;

Info.mrtim.method = 'mrtim';
Info.mrtim.nLayers = 12;
Info.mrtim.mriSegmented = [cfgMRTIM.output '\mri_segmented.mat'];
Info.mrtim.mriPrepro = [cfgMRTIM.output '\anatomy_prepro.nii'];
%%
segmentation_mrtim(cfgMRTIM);

%% Ground Truth Comaparison
%method = 'fieldtrip';
method = 'mrtim';
%cfgGT.swap = true;

cfgGT = struct;
cfgGT.seg.segmentation = Info.(method).mriSegmented;
cfgGT.seg.prepro = Info.(method).mriPrepro;
cfgGT.seg.method = Info.(method).method;
cfgGT.seg.nLayers = Info.(method).nLayers;
if cfgGT.seg.method == "mrtim"
    cfgGT.omit = {'sinus'};
end

cfgGT.output = char(Path.result); % output path as string
cfgGT.visualize = true;
%%
[Result, MaskResult] = compare_ground_truth(cfgGT);

%% Relative Comparison
cfgRel = struct;
cfgRel.seg1.segmentation = Info.fieldtrip.mriSegmented;
cfgRel.seg1.prepro = Info.fieldtrip.mriPrepro;
cfgRel.seg1.method = Info.fieldtrip.method;
cfgRel.seg1.nLayers = Info.fieldtrip.nLayers;

cfgRel.seg2.segmentation = Info.mrtim.mriSegmented;
cfgRel.seg2.prepro = Info.mrtim.mriPrepro;
cfgRel.seg2.method = Info.mrtim.method;
cfgRel.seg2.nLayers = Info.mrtim.nLayers;

cfgRel.output = Path.result; % output path as string
cfgRel.visualize = true;
%%
[Result, MaskResult] = compare_segmentations(cfgRel);
