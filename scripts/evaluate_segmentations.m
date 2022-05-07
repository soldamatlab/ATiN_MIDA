%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Paths & Names - Set manually
%Path.output.root = 'S:\BP_MIDA\analysis'; % PC-MATOUS
Path.output.root = '\\Pc-matous\bp_mida\analysis'; % PC-MATOUS remote
%Path.output.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\analysis'; % NTB
%Path.output.root = 'S:\matous\analysis'; % PC-SIMON
Path.output.NUDZ = [Path.output.root '\NUDZ'];
Path.output.BINO = [Path.output.root '\BINO'];

% dataset:
dataset = 'NUDZ';
%dataset = 'BINO';

methods =  {'fieldtrip',      'fieldtrip',      'mrtim'};
layers =   [ 3,                5,                12    ];
suffixes = {'anatomy_prepro', 'anatomy_prepro', ''     };

segFileName = 'mri_segmented.mat';
preproFileName = struct;
preproFileName.default = 'mri_prepro.mat';
preproFileName.mrtim = 'anatomy_prepro.nii';

%% Find subjects
methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);
segFileName = convertStringsToChars(segFileName);
preproFileName.default = convertStringsToChars(preproFileName.default);
preproFileName.mrtim = convertStringsToChars(preproFileName.mrtim);

%% Find subjects
[segmentations, nSegmentations] = get_segmentation_names(methods, layers, suffixes);
pairs = nchoosek(1:nSegmentations, 2);
nPairs = size(pairs, 1);
if strcmp(dataset, 'NUDZ')
    subjects = dir([Path.output.NUDZ '\*_*_*']);
elseif strcmp(dataset, 'BINO')
    subjects = dir([Path.output.BINO '\S*']);
else
    error("Unknown dataset")
end
nSubjects = length(subjects);

finished = NaN(nSubjects, 2*nPairs);
for s = 1:nSubjects
    %% Get subject-relative paths
    Path.(subjects(s).name).root = [subjects(s).folder '\' subjects(s).name];
    Path.(subjects(s).name).segmentation.root = [Path.(subjects(s).name).root '\segmentation'];
    Path.(subjects(s).name).evaluation.root = [Path.(subjects(s).name).root '\evaluation'];
    Path.(subjects(s).name).evaluation.segCompare = [Path.(subjects(s).name).evaluation.root '\compare_segmentations'];
    for m = 1:nSegmentations
        Path.(subjects(s).name).segmentation.(segmentations{m}).root = [Path.(subjects(s).name).segmentation.root '\' segmentations{m}];
        Path.(subjects(s).name).segmentation.(segmentations{m}).seg = [Path.(subjects(s).name).segmentation.(segmentations{m}).root '\' segFileName];
        if strcmp(methods{m}, 'mrtim')
            preproName = preproFileName.mrtim;
        else
            preproName = preproFileName.default;
        end
        Path.(subjects(s).name).segmentation.(segmentations{m}).prepro = [Path.(subjects(s).name).segmentation.(segmentations{m}).root '\' preproName];
    end
    
    %% Compare segmentations with each other
    for p = 1:nPairs
        idx1 = pairs(p,1);
        idx2 = pairs(p,2);
        
        cfgRel = struct;
        
        cfgRel.seg1.segmentation = Path.(subjects(s).name).segmentation.(segmentations{idx1}).seg;
        cfgRel.seg1.prepro = Path.(subjects(s).name).segmentation.(segmentations{idx1}).prepro;
        cfgRel.seg1.method = methods{idx1};
        cfgRel.seg1.nLayers = layers(idx1);
        cfgRel.seg1.suffix = suffixes{idx1};
        
        cfgRel.seg2.segmentation = Path.(subjects(s).name).segmentation.(segmentations{idx2}).seg;
        cfgRel.seg2.prepro = Path.(subjects(s).name).segmentation.(segmentations{idx2}).prepro;
        cfgRel.seg2.method = methods{idx2};
        cfgRel.seg2.nLayers = layers(idx2);
        cfgRel.seg2.suffix = suffixes{idx2};
        
        cfgRel.output = Path.(subjects(s).name).evaluation.segCompare;
        cfgRel.visualize = false;
        
        name = sprintf('Compare %s with %s', segmentations{idx1}, segmentations{idx2});
        finished(s,2*(p-1)+1) = run_submodule(@compare_segmentations, cfgRel, name);
        
        tmp = cfgRel.seg1;
        cfgRel.seg1 = cfgRel.seg2;
        cfgRel.seg2 = tmp;
        
        name = sprintf('Compare %s with %s', segmentations{idx2}, segmentations{idx1});
        finished(s,2*p) = run_submodule(@compare_segmentations, cfgRel, name);
    end
end
