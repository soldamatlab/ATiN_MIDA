%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Paths & Config
Path.toolbox.mrtim = [matlabroot '\toolbox\spm12\toolbox\MRTIM'];
Path.output = 'S:\BP_MIDA\analysis';
Path.mrtimSeg = '\segmentation\mrtim12';

Path.data.nudz.root = 'S:\BP_MIDA\data\MR';
Path.data.bino.root = 'S:\BP_MIDA\data\BINO\Structural';
Path.output = 'S:\BP_MIDA\analysis';

%dataset = 'nudz';
dataset = 'bino';

%% Find & Convert & Segment data
if strcmp(dataset, 'nudz')
    subjects = dir([Path.data.(dataset).root '\*_*_*']);
elseif strcmp(dataset, 'bino')
    subjects = dir([Path.data.(dataset).root '\S*']);
end

cfgFindDir = struct;
cfgFindDir.dir = true;

cfgFindIMA = struct;
cfgFindIMA.max = false;

cfgVolumeWrite = struct;
cfgVolumeWrite.parameter = 'anatomy';
cfgVolumeWrite.filetype = 'nifti';

cfgPipeline = struct;
cfgPipeline.resultsPath = Path.output;
if strcmp(dataset, 'nudz')
    cfgPipeline.dataName = 'NUDZ';
elseif strcmp(dataset, 'bino')
    cfgPipeline.dataName = 'BINO';
end
cfgPipeline.visualize = false;
cfgPipeline.dialog = false;

nFiles = length(subjects);
for f = 1:nFiles
    fprintf("SEGMENTING SUBJECT '%s'\n", subjects(f).name)
    %% Find data
    if strcmp(dataset, 'nudz')
        mriDir = find_in_dir(subjects(f), 'HEAD_VP03_GTEN_*', cfgFindDir);
        T1Dir = find_in_dir(mriDir, 'T1_SAG_MPR_3D_1MM_ISO_P2_*', cfgFindDir);
        imaFiles = find_in_dir(T1Dir, '*.IMA', cfgFindIMA);
    elseif strcmp(dataset, 'bino')
        T1Dir = find_in_dir(subjects(f), '*t1_sag_mpr_3D_*', cfgFindDir);
        imaFiles = find_in_dir(T1Dir, '*MR.*', cfgFindIMA);
    end
    Path.data.(dataset).(subjects(f).name).ima = [imaFiles(1).folder '\' imaFiles(1).name];
    niftiFileName = [T1Dir.folder '\' T1Dir.name];
    Path.data.(dataset).(subjects(f).name).nifti = [niftiFileName '.nii'];
    
    %% Convert DICOM to NIFTI
    niftiFile = dir(Path.data.(dataset).(subjects(f).name).nifti);
    if isempty(niftiFile)
        mri = ft_read_mri(Path.data.(dataset).(subjects(f).name).ima);
        cfgVolumeWrite.filename = niftiFileName;
        ft_volumewrite(cfgVolumeWrite, mri);
    end
    
    %% Segment
    cfg = cfgPipeline;
    cfg.subjectName = subjects(f).name;
    cfg.segmentation.mrtim.nLayers = 12;
    cfg.segmentation.mrtim.mri = Path.data.(dataset).(subjects(f).name).nifti;
    cfg.segmentation.mrtim.path.mrtim = Path.toolbox.mrtim;
    forward_problem_pipeline(cfg);

    cfg = cfgPipeline;
    cfg.subjectName = subjects(f).name;
    cfg.segmentation.fieldtrip.nLayers = [3 5];
    cfg.segmentation.fieldtrip.mriPrepro = [Path.output '\' cfgPipeline.dataName '\' subjects(f).name Path.mrtimSeg '\anatomy_prepro.nii'];
    cfg.segmentation.fieldtrip.coordsys = 'acpc';
    cfg.segmentation.fieldtrip.suffix = 'anatomy_prepro';
    forward_problem_pipeline(cfg);
end
