%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Paths & Names - Set manually
Path.output.root = 'S:\BP_MIDA\analysis';
Path.output.nudz = [Path.output.root '\NUDZ'];

methods =  {'fieldtrip',                 'mrtim'};
layers =   [ 5,                           12    ];
suffixes = {'anatomy_prepro',            ''     };

segFileName = 'mri_segmented.mat';
sourcemodelFileName = 'sourcemodel.mat';
sourcemodelVarName = 'sourcemodel';

%% Get paths to segmentations
methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);
segFileName = convertStringsToChars(segFileName);
sourcemodelFileName = convertStringsToChars(sourcemodelFileName);

nSegmentations = length(methods);
segmentations = cell(1, nSegmentations);
for m = 1:nSegmentations
    suffix = '';
    if ~isempty(suffixes{m})
        suffix = ['_' suffixes{m}];
    end
    segmentations{m} = [methods{m} num2str(layers(m)) suffix];
end

subjects = dir([Path.output.nudz '\*_*_*']);
nSubjects = length(subjects);
for s = 1:nSubjects
    for m = 1:nSegmentations
        Path.(subjects(s).name).segmentation.(segmentations{m}) =...
            [subjects(s).folder '\' subjects(s).name '\segmentation\' segmentations{m} '\' segFileName];
        Path.(subjects(s).name).sourcemodel.(segmentations{m}) =...
            [subjects(s).folder '\' subjects(s).name '\model\' segmentations{m} '\' sourcemodelFileName];
    end
end

%% Prepare models
cfgPipeline = struct;
cfgPipeline.resultsPath = Path.output.root;
cfgPipeline.dataName = 'NUDZ';
cfgPipeline.visualize = false;
cfgPipeline.dialog = false;

modelFT = struct;
modelFT.mriSegmented.method = methods;
modelFT.mriSegmented.nLayers = layers;
modelFT.suffix = suffixes;
modelFT.sourcemodel = 'matchpos';

sourcemodelCheck = NaN(nSubjects, 1);
pairs = nchoosek(1:nSegmentations, 2);
nPairs = size(pairs, 1);
for s = 1:nSubjects
    cfgPipeline.subjectName = subjects(s).name;
    modelFT.mriSegmented.path = cell(1, nSegmentations);
    for m = 1:nSegmentations
        modelFT.mriSegmented.path{m} = Path.(subjects(s).name).segmentation.(segmentations{m});
    end 
    cfgPipeline.model.fieldtrip = modelFT;
    forward_problem_pipeline(cfgPipeline);
    
    %% Check if sourcemodels match
    sourcemodels = cell(1, nSegmentations);
    for m = 1:nSegmentations
        sourcemodels{m} = load(Path.(subjects(s).name).sourcemodel.(segmentations{m}), 'sourcemodel');
    end
    for p = 1:nPairs
        sourcemodelA = sourcemodels{pairs(p,1)}.sourcemodel;
        sourcemodelB = sourcemodels{pairs(p,2)}.sourcemodel;
        if ~isequal(sourcemodelA.pos, sourcemodelB.pos)...
                || ~isequal(sourcemodelA.dim, sourcemodelB.dim)
            sourcemodelCheck(s) = false;
        else
            sourcemodelCheck(s) = true;
        end
    end
end
