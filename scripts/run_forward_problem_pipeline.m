% This script demonstrates the use of 'forward_problem_pipeline' function.
%% Innit
clear variables
close all
addpath_source;
cfg = struct;

%% Define local paths
% TOOLBOXES
fieldtripPath = [matlabroot '\toolbox\fieldtrip'];
spmPath = [matlabroot '\toolbox\spm12'];
mrtimPath = [matlabroot '\toolbox\spm12\toolbox\MRTIM'];

% DATA
dataPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data';
mriDataPath = [dataPath '\data\MR\ANDROVICOVA_RENATA_8753138768\HEAD_VP03_GTEN_20181204_120528_089000\T1_SAG_MPR_3D_1MM_ISO_P2_0002'];
mriPathIMA = [mriDataPath '\ANDROVICOVA_RENATA.MR.HEAD_VP03_GTEN.0002.0001.2018.12.12.08.59.13.218838.497728628.IMA'];
mriPathNII = [mriDataPath '\T1_SAG_MPR_3D_1MM_ISO_P2_0002_t1_sag_mpr_3D_1mm_ISO_p2_20181204120528_2.nii'];

%% Output path
% Define database structure:
% (Results will be saved in 'resultsPath\analysisName\dataName\runName'.)
cfg.resultsPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out';
cfg.dataName = 'NUDZ';
cfg.subjectName = 'ANDROVICOVA_RENATA';
%cfg.runName = '01';

% or

% Define a simple path:
% (This will override the previous option.)
cfg.output = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\simple_path';

% Note that setting [.output] in any of the submodules will have no
% effect. Output paths for submodules are generated by the pipeline.

%% ___ Segmentation ______________________________________________________
% Uncomment one or more segmentation methods below:

%% Segmentation - File (Load already segmented MRI from a .mat file)
cfg.segmentation.file.path = [dataPath '\out\pipeline_test\ANDROVICOVA_RENATA\03\segmentation\fieldtrip\mri_segmented.mat'];
% or
% TODO add option file.mat instead of file.path

% 'fieldtrip' or 'mrtim' are supported
cfg.segmentation.file.method = 'fieldtrip';

% 5 for 'fieldtrip', 6 or 12 for 'mrtim'
cfg.segmentation.file.nLayers = 5;

% Optional:
% Transformation matrix from norm space to individual space.
% If not provided, norm space will be assumed.
cfg.segmentation.file.norm2ind = [dataPath '\out\pipeline_test\ANDROVICOVA_RENATA\03\segmentation\fieldtrip\norm2ind.mat'];

%% Segmentation - FieldTrip
% See 'segmentation\fieldtrip\run_segmentation_fieldtrip.m' for all options
cfg.segmentation.fieldtrip.path.fieldtrip = fieldtripPath;
cfg.segmentation.fieldtrip.mri = mriPathIMA; % TODO add support for var instead of path

%% Segmentation - MR-TIM
% See 'segmentation\mrtim\run_segmentation_mrtim.m' for all options
cfg.segmentation.mrtim.path.spm = spmPath;
cfg.segmentation.mrtim.path.mrtim = mrtimPath;
cfg.segmentation.mrtim.mri = mriPathNII;
cfg.segmentation.mrtim.nLayers = 12;

%% ___ Model _____________________________________________________________
% Uncomment one or more modeling methods below:

%% Model - FieldTrip
% See 'model\fieldtrip\run_model_fieldtrip.m' for all options
cfg.model.fieldtrip.path.fieldtrip = fieldtripPath;

% Specify a previous segmentation submodule to follow up on:
% Choose one or multiple from {'fieldtrip', 'mrtim', 'brainstorm', 'file'}.
% or
% Use 'all' to process all segmented MRIs from previous step.
cfg.model.fieldtrip.mriSegmented = {'fieldtrip', 'mrtim'};
%cfg.model.fieldtrip.mriSegmented = 'all';

%% ___ Miscellaneous _____________________________________________________
% If set, it will override all submodule 'visualize' options.
cfg.visualize = true;

% Disables user dialog in case of already existing output folder.
% Useful for automatic runs of the pipeline.
%cfg.dialog = false;

% Useful for manual run of parts of the pipeline:
%Config = cfg; clear cfg;

%% ___ Run _______________________________________________________________
forward_problem_pipeline(cfg);
