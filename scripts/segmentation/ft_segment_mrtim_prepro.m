%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Define paths
nudzAnalysisPath = 'S:\BP_MIDA\analysis\NUDZ';
subjects = dir([nudzAnalysisPath '\*_*_*']);
subpathMrtim = '\segmentation\mrtim12';

%% Config
cfgPipeline = struct;
cfgPipeline.visualize = false;
cfgPipeline.dialog = false;
cfgFT = struct;
cfgFT.nLayers = [3 5];
cfgFT.coordsys = 'acpc';
cfgFT.suffix = 'anatomy_prepro';

%% Segment
nFiles = length(subjects);
for f = 1:nFiles
    fprintf("SEGMENTING SUBJECT '%s'\n", subjects(s).name)
    subjectPath = [subjects(f).folder '\' subjects(f).name];
    cfgFT.mriPrepro = [subjectPath subpathMrtim '\anatomy_prepro.nii'];
    cfgPipeline.segmentation.fieldtrip = cfgFT;
    cfgPipeline.output = subjectPath;
 
    %segmentation_fieldtrip(cfgFT);
    forward_problem_pipeline(cfgPipeline);
end
