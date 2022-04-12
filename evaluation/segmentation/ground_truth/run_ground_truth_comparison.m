%% Init
clear variables
close all

Info = struct;

%% Define paths
%wd = fileparts(mfilename('fullpath')); % for automatic run
%wd = './';
wd = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project\evaluation\segmentation\ground_truth'; 
Path = struct;

% Data:
Path.data = [wd '\..\..\..\data'];
Path.mri = [Path.data '\SCI\T1\patient\IM-0001-0001.dcm'];
Path.mriNII = [Path.data '\SCI_data\T1\patientNII\mri.nii'];

% Toolboxes:
Path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];
Path.spm = [matlabroot '\toolbox\spm12'];
Path.mrtim = [matlabroot '\toolbox\spm12\toolbox\mrtim'];

% Submodules:
Path.source.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project';
Path.source.segmentation = [Path.source.root '\forward_problem_pipeline\segmentation'];
Path.source.segmentationFT = [Path.source.segmentation '\fieldtrip'];
Path.source.segmentationMRTIM = [Path.source.segmentation '\mrtim'];
Path.source.nrrd = [Path.source.root '\external\nrrd_read_write_rensonnet'];

% Output:
Path.data = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data';
Path.output = [Path.data '\out\ground_truth_segmentation_test'];
Path.segmentation = [Path.output '\segmentation'];
Path.segmentationFT = [Path.segmentation '\fieldtrip'];
Path.segmentationMRTIM = [Path.segmentation '\mrtim'];
Path.result = [Path.output '\evaluation'];

%% Segment MRI by FieldTrip
% See 'run_segmentation_fieldtrip.m'
cfgFT = struct;
cfgFT.path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];
cfgFT.nLayers = 3;
cfgFT.output = [Path.segmentationFT num2str(cfgFT.nLayers)]; % output path as string
cfgFT.mri = Path.mri;
cfgFT.visualize = true;

addpath(Path.source.segmentationFT)
mriSegmented = segmentation_fieldtrip(cfgFT);
%%
Info.segmentation.method = 'fieldtrip';
Info.segmentation.nLayers = cfgFT.nLayers;
Info.segmentation.mriSegmented = [cfgFT.output '\mri_segmented.mat'];
Info.segmentation.mriPrepro = [cfgFT.output '\mri_prepro.mat'];

%% Segment MRI by MR-TIM
% See 'run_segmentation_mrtim.m'
cfgMRTIM = struct;
cfgMRTIM.path.spm = Path.spm;
cfgMRTIM.path.mrtim = Path.mrtim;
cfgMRTIM.output = Path.segmentationMRTIM; % output path as string
cfgMRTIM.mri = [Path.mriNII ',1'];

addpath(Path.source.segmentationMRTIM)
segmentation_mrtim(cfgMRTIM);
%%
Info.segmentation.method = 'mrtim';
Info.segmentation.nLayers = 12;
Info.segmentation.mriSegmented = [cfgMRTIM.output '\mri_segmented.mat'];
Info.segmentation.mriPrepro = [cfgMRTIM.output '\anatomy_prepro.nii']; % TODO ? anatomy_prepro_mni.nii

%% Ground Truth Comaparison
cfgGT = struct;
cfgGT.path.fieldtrip = Path.fieldtrip;
cfgGT.output = Path.result; % output path as string
cfgGT.visualize = true;

cfgGT.mriSegmented.method = Info.segmentation.method;
cfgGT.mriSegmented.nLayers = Info.segmentation.nLayers;
% TODO better
if Info.segmentation.nLayers == 3
    cfgGT.mriSegmented.colormap = lines(4);
elseif Info.segmentation.nLayers == 5
    cfgGT.mriSegmented.colormap = lines(6);
elseif Info.segmentation.nLayers == 12
    cfgGT.mriSegmented.colormap = [prism(3); lines(7); parula(2)]; % TODO
end
%%
[Result, MaskResult] = ground_truth_comparison(cfgGT, Info.segmentation.mriSegmented, Info.segmentation.mriPrepro);
