%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data'; % NTB
Path.root = 'S:\BP_MIDA'; % PC-MATOUS
%Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote
%Path.root = 'S:\matous'; % PC-SIMON

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
%modelFT.sourcemodel = 'matchpos';

posdimCheck = NaN(nSubjects, 1);
for s = 1:nSubjects
    fprintf("MODELING SUBJECT '%s'\n", subjects(s).name)
    mriSegmented = cell(1, nSegmentations);
    for m = 1:nSegmentations
        mriSegmented{m} = load_var_from_mat('mriSegmented', Path.(subjects(s).name).segmentation.(segmentations{m}));
        cfg = struct;
        cfg.method = methods{m};
        cfg.nLayers = layers(m);
        mriSegmented{m} = prepare_gray(cfg, mriSegmented{m});
    end
    [pos, dim] = prepare_sourcepos(mriSegmented);
    
    sourcemodel = load_var_from_mat('sourcemodel', Path.(subjects(s).name).sourcemodel.(segmentations{3}));
    if ~(isequal(pos, sourcemodel.pos) && isequal(dim, sourcemodel.dim))
        posdimCheck(s) = -1;
        continue;
    else
        posdimCheck(s) = 0;
    end
    
    modelFT.sourcemodel = struct;
    modelFT.sourcemodel.pos = sourcemodel.pos;
    modelFT.sourcemodel.dim = sourcemodel.dim;
    cfgPipeline.subjectName = subjects(s).name;
    modelFT.mriSegmented.path = cell(1, nSegmentations);
    for m = 1:nSegmentations
        modelFT.mriSegmented.path{m} = Path.(subjects(s).name).segmentation.(segmentations{m});
    end
    cfgPipeline.model.fieldtrip = modelFT;
    forward_problem_pipeline(cfgPipeline);
end
