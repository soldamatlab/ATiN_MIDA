%% Define paths
Source = struct;
Source.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project';
Source.common = [Source.root '\common'];
Source.pipeline = [Source.root '\forward_problem_pipeline'];
Source.segmentation.root = [Source.root '\forward_problem_pipeline\segmentation'];
Source.segmentation.fieldtrip = [Source.segmentation.root '\fieldtrip'];
Source.segmentation.mrtim = [Source.segmentation.root '\mrtim'];

Path.fieldtrip = [matlabroot '\toolbox\fieldtrip'];
Path.spm = [matlabroot '\toolbox\spm12'];
Path.mrtim = [matlabroot '\toolbox\spm12\toolbox\mrtim'];

Path.data.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data';
Path.data.nudz.root = [Path.data.root '\MR'];

Path.output = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\analysis';

%% Import source code & Init toolboxes
addpath(Source.common)
addpath(Source.pipeline)

addpath(Path.mrtim)
addpath(Path.fieldtrip)
ft_defaults

%% Find & Convert & Segment data
subjects = dir([Path.data.nudz.root '\*_*_*']);

cfgFindDir = struct;
cfgFindDir.dir = true;

cfgFindIMA = struct;
cfgFindIMA.max = false;

cfgVolumeWrite = struct;
cfgVolumeWrite.parameter = 'anatomy';
cfgVolumeWrite.filetype = 'nifti';

cfgPipeline = struct;
cfgPipeline.resultsPath = Path.output;
cfgPipeline.dataName = 'NUDZ';
cfgPipeline.visualize = false;
cfgPipeline.dialog = false;
cfgPipeline.segmentation.fieldtrip.path.fieldtrip = Path.fieldtrip;
cfgPipeline.segmentation.fieldtrip.nLayers = [3 5];
cfgPipeline.segmentation.mrtim.path.spm = Path.spm;
cfgPipeline.segmentation.mrtim.path.mrtim = Path.mrtim;
cfgPipeline.segmentation.mrtim.path.fieldtrip = Path.fieldtrip;
cfgPipeline.segmentation.mrtim.nLayers = 12;

nFiles = length(subjects);
for f = 1:nFiles
    %% Find data
    mriDir = find_in_dir(subjects(f), 'HEAD_VP03_GTEN_*', cfgFindDir);
    T1Dir = find_in_dir(mriDir, 'T1_SAG_MPR_3D_1MM_ISO_P2_*', cfgFindDir);
    imaFiles = find_in_dir(T1Dir, '*.IMA', cfgFindIMA);
    Path.data.nudz.(subjects(f).name).ima = [imaFiles(1).folder '\' imaFiles(1).name];
    niftiFileName = [T1Dir.folder '\' T1Dir.name];
    Path.data.nudz.(subjects(f).name).nifti = [niftiFileName '.nii'];
    
    %% Convert DICOM to NIFTI
    niftiFile = dir(Path.data.nudz.(subjects(f).name).nifti);
    if isempty(niftiFile)
        mri = ft_read_mri(Path.data.nudz.(subjects(f).name).ima);
        cfgVolumeWrite.filename = niftiFileName;
        ft_volumewrite(cfgVolumeWrite, mri);
    end
    
    %% Segment
    cfgPipeline.subjectName = subjects(f).name;
    cfgPipeline.segmentation.fieldtrip.mri = Path.data.nudz.(subjects(f).name).ima;
    cfgPipeline.segmentation.mrtim.mri = Path.data.nudz.(subjects(f).name).nifti;
    forward_problem_pipeline(cfgPipeline);
end
