%% Init
clear variables
close all
Info = struct;

%% Define paths
%wd = fileparts(mfilename('fullpath')); % for automatic run
%wd = './';
wd = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project\evaluation\segmentation\compare'; 
addpath(genpath(wd));

Path = struct;
% Data:
Path.data = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
Path.mri = [Path.data '\SCI\T1\patient\IM-0001-0001.dcm'];
Path.mriNII = [Path.data '\SCI\T1\patient.nii'];
%Path.mriPath = [Path.data '\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002'];
%Path.mri = [Path.mriPath '\ANDROVICOVA_RENATA.MR.HEAD_VP03_GTEN.0002.0001.2018.12.12.08.59.13.218838.497728628.IMA'];
%Path.mriNII = [Path.mriPath '\T1_SAG_MPR_3D_1MM_ISO_P2_0002_t1_sag_mpr_3D_1mm_ISO_p2_20181204120528_2.nii'];

% Toolboxes:
Path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];
Path.spm = [matlabroot '\toolbox\spm12'];
Path.mrtim = [matlabroot '\toolbox\spm12\toolbox\MRTIM'];

% Submodules:
Path.source.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project';
Path.source.segmentation = [Path.source.root '\forward_problem_pipeline\segmentation'];
Path.source.segmentationFT = [Path.source.segmentation '\fieldtrip'];
Path.source.segmentationMRTIM = [Path.source.segmentation '\mrtim'];
Path.source.nrrd = [Path.source.root '\external\nrrd_read_write_rensonnet'];

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
cfgFT.path.fieldtrip = Path.fieldtrip;
cfgFT.nLayers = 5;
cfgFT.output = [Path.segmentationFT num2str(cfgFT.nLayers)]; % output path as string
cfgFT.mri = Path.mri;
cfgFT.visualize = true;

Info.fieldtrip.method = 'fieldtrip';
Info.fieldtrip.nLayers = cfgFT.nLayers;
Info.fieldtrip.mriSegmented = [cfgFT.output '\mri_segmented.mat'];
Info.fieldtrip.mriPrepro = [cfgFT.output '\mri_prepro.mat'];
%% TODO uncomment
%addpath(Path.source.segmentationFT)
%mriSegmented = segmentation_fieldtrip(cfgFT);

%% Segment MRI by MR-TIM
% See 'run_segmentation_mrtim.m'
cfgMRTIM = struct;
cfgMRTIM.path.spm = Path.spm;
cfgMRTIM.path.mrtim = Path.mrtim;
cfgMRTIM.path.fieldtrip = Path.fieldtrip;
cfgMRTIM.nLayers = 12;
cfgMRTIM.output = [Path.segmentationMRTIM num2str(cfgMRTIM.nLayers)]; % output path as string
cfgMRTIM.mri = Path.mriNII;

Info.mrtim.method = 'mrtim';
Info.mrtim.nLayers = 12;
Info.mrtim.mriSegmented = [cfgMRTIM.output '\mri_segmented.mat'];
Info.mrtim.mriPrepro = [cfgMRTIM.output '\anatomy_prepro.nii']; % TODO ? anatomy_prepro_mni.nii
%%
addpath(Path.source.segmentationMRTIM)
segmentation_mrtim(cfgMRTIM);

%% Ground Truth Comaparison
method = 'fieldtrip';
%method = 'mrtim';

cfgGT = struct;
cfgGT.seg.segmentation = Info.(method).mriSegmented;
cfgGT.seg.prepro = Info.(method).mriPrepro;
cfgGT.seg.method = Info.(method).method;
cfgGT.seg.nLayers = Info.(method).nLayers;
if cfgGT.seg.method == "mrtim"
    cfgGT.omit = {'sinus'};
end
% TODO better
if cfgGT.seg.nLayers == 3
    cfgGT.seg.colormap = lines(4);
elseif cfgGT.seg.nLayers == 5
    cfgGT.seg.colormap = lines(6);
elseif cfgGT.seg.nLayers == 12
    cfgGT.seg.colormap = [prism(3); lines(7); parula(2)]; % TODO
end

cfgGT.path.fieldtrip = Path.fieldtrip;
segName = [char(cfgGT.seg.method) sprintf('%d',cfgGT.seg.nLayers)];
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
% TODO better
if cfgRel.seg1.nLayers == 3
    cfgRel.seg1.colormap = lines(4);
elseif cfgRel.seg1.nLayers == 5
    cfgRel.seg1.colormap = lines(6);
elseif cfgRel.seg1.nLayers == 12
    cfgRel.seg1.colormap = [prism(3); lines(7); parula(2)]; % TODO
end
%%
cfgRel.seg2.segmentation = Info.mrtim.mriSegmented;
cfgRel.seg2.prepro = Info.mrtim.mriPrepro;
cfgRel.seg2.method = Info.mrtim.method;
cfgRel.seg2.nLayers = Info.mrtim.nLayers;
% TODO better
if cfgRel.seg2.nLayers == 3
    cfgRel.seg2.colormap = lines(4);
elseif cfgRel.seg2.nLayers == 5
    cfgRel.seg2.colormap = lines(6);
elseif cfgRel.seg2.nLayers == 12
    cfgRel.seg2.colormap = [prism(3); lines(7); parula(2)]; % TODO
end
%%
cfgRel.path.fieldtrip = Path.fieldtrip;
seg1name = [char(cfgRel.seg1.method) sprintf('%d',cfgRel.seg1.nLayers)];
seg2name = [char(cfgRel.seg2.method) sprintf('%d',cfgRel.seg2.nLayers)];
cfgRel.output = Path.result; % output path as string
cfgRel.visualize = true;
%%
[Result, MaskResult] = compare_segmentations(cfgRel);
