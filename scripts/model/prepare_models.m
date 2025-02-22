%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Paths & Config - Set manually
% Local paths:
Path.root = 'S:\BP_MIDA'; % PC-MATOUS
%Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote

Path.data.root = [Path.root '\data'];
Path.data.NUDZ = [Path.data.root '\MR'];
Path.data.BINO = [Path.data.root '\BINO'];
Path.output.root = [Path.root '\analysis'];
Path.output.NUDZ = [Path.output.root '\NUDZ'];
Path.output.BINO = [Path.output.root '\BINO'];

% dataset:
%dataset = 'NUDZ';
dataset = 'BINO';

% Segmentations:
methods =  {'fieldtrip',      'fieldtrip',                 'mrtim'};
layers =   [ 3,                5,                           12    ];
suffixes = {'anatomy_prepro', 'anatomy_prepro',            ''     };

% Filenames:
segFileName = 'mri_segmented.mat';
sourcemodelFileName = 'sourcemodel.mat';
sourcemodelVarName = 'sourcemodel';

%% Get paths to segmentations
methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);
segFileName = convertStringsToChars(segFileName);
sourcemodelFileName = convertStringsToChars(sourcemodelFileName);
[segmentations, nSegmentations] = get_segmentation_names(methods, layers, suffixes);

if strcmp(dataset, 'NUDZ')
    subjects = dir([Path.output.NUDZ '\*_*_*']);
elseif strcmp(dataset, 'BINO')
    subjects = dir([Path.output.BINO '\S*']);
else
    error("Unknown dataset")
end
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
cfgPipeline.dataName = dataset;
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
    fprintf("MODELING SUBJECT '%s'\n", subjects(s).name)
    cfgPipeline.subjectName = subjects(s).name;
    modelFT.mriSegmented.path = cell(1, nSegmentations);
    for m = 1:nSegmentations
        modelFT.mriSegmented.path{m} = Path.(subjects(s).name).segmentation.(segmentations{m});
    end
    cfgPipeline.model.fieldtrip = modelFT;
    forward_problem_pipeline(cfgPipeline);
    
    %% Check if sourcemodels match
    sourcemodels = cell(1, nSegmentations);
    loadError = false;
    for m = 1:nSegmentations
        try
            sourcemodels{m} = load(Path.(subjects(s).name).sourcemodel.(segmentations{m}), 'sourcemodel');
        catch
            warning("Could not load sourcemodels to check if they match.")
            sourcemodelCheck(s) = 1;
            loadError = true;
            break
        end
    end
    if loadError
        continue
    end
    for p = 1:nPairs
        sourcemodelA = sourcemodels{pairs(p,1)}.sourcemodel;
        sourcemodelB = sourcemodels{pairs(p,2)}.sourcemodel;
        if ~isequal(sourcemodelA.pos, sourcemodelB.pos)...
                || ~isequal(sourcemodelA.dim, sourcemodelB.dim)
            sourcemodelCheck(s) = 2;
        else
            sourcemodelCheck(s) = 0;
        end
    end
end
