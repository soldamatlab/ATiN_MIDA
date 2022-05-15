%% Import source code & Init toolboxes
close all
clear variables
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data'; % NTB
%Path.root = 'S:\BP_MIDA'; % PC-MATOUS
Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote
%Path.root = 'S:\matous'; % PC-SIMON

Path.data.root = [Path.root '\data'];
Path.data.BINO.root = [Path.data.root '\BINO'];
Path.data.BINO.EEG = [Path.data.BINO.root '\EEG'];
Path.output.root = [Path.root '\analysis'];
Path.output.BINO = [Path.output.root '\BINO'];

% Segmentations:
methods =  {'fieldtrip',      'fieldtrip',                 'mrtim'};
layers =   [ 3,                5,                           12    ];
suffixes = {'anatomy_prepro', 'anatomy_prepro',            ''     };

%% Filenames
SOURCEMODEL_FILE_NAME = 'sourcemodel.mat';
SOURCEMODEL_VAR_NAME = 'sourcemodel';
HEADMODEL_FILE_NAME = 'headmodel.mat';
HEADMODEL_VAR_NAME = 'headmodel';
%ELEC_FILE_NAME = 'elec.mat';
%ELEC_VAR_NAME = 'elec';

PREPRO_FILE_NAME_FIELDTRIP = 'mri_prepro.mat';
PREPRO_FILE_NAME_MRTIM = 'anatomy_prepro.nii';
PREPRO_VAR_NAME = 'mriPrepro';

preproFileName = struct;
preproFileName.fieldtrip = PREPRO_FILE_NAME_FIELDTRIP;
preproFileName.mrtim = PREPRO_FILE_NAME_MRTIM;

%% Get paths to models
methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);
[segmentations, nSegmentations] = get_segmentation_names(methods, layers, suffixes);

subjects = dir([Path.output.BINO '\S*']);
nSubjects = length(subjects);
for s = 1:nSubjects
    for m = 1:nSegmentations
        Path.(subjects(s).name).model.(segmentations{m}) =...
            [subjects(s).folder '\' subjects(s).name '\model\' segmentations{m}];
        Path.(subjects(s).name).mriPrepro.(segmentations{m}) =...
            [subjects(s).folder '\' subjects(s).name '\segmentation\' segmentations{m} '\' preproFileName.(methods{m})];
    end
end

datas = dir([Path.data.BINO.EEG '\bino-*_*_*_cut.mat']);
nDatas = length(datas);
if nDatas ~= nSubjects
    error('nDatas ~= nSubjects')
end
for d = 1:nDatas
    dataIdx = sscanf(datas(d).name, 'bino-%d_%d_%d_cut.mat');
    dataIdx = dataIdx(1);
    subjectIdx = sscanf(subjects(d).name, 'S%d');
    if dataIdx ~= subjectIdx
        error("dataIdx ~= subjectIdx: subject '%s'; data '%s'", subjects(d).name, datas(d).name)
    end
    Path.(subjects(d).name).data = [datas(d).folder '\' datas(d).name];
end

%% Localize sources
cfg = struct;
cfg.channel = 1:256;
cfg.rereference = 'avg';

cfg.plot = true;
cfg.visualize = false;

finished = NaN(nSubjects, nSegmentations);
for s = 1:nSubjects
    for m = 1:nSegmentations
        modelPath = Path.(subjects(s).name).model.(segmentations{m});
        cfg.output = sprintf('%s%s%s', modelPath, '\..\..\evaluation\stimulation\', segmentations{m});
        if exist(cfg.output, 'dir')
            warning("Folder '%s' already exists.\n Skipping subject '%s' model '%s'.", cfg.output, subjects(s).name, segmentations{m})
            continue
        end
        
        load(Path.(subjects(s).name).data); % inits vars 'data' and 'events'
        cfg.data = data;
        cfg.events = events;
        
        cfg.sourcemodel = load_var_from_mat(SOURCEMODEL_VAR_NAME, [modelPath '\' SOURCEMODEL_FILE_NAME]);
        cfg.headmodel = load_var_from_mat(HEADMODEL_VAR_NAME, [modelPath '\' HEADMODEL_FILE_NAME]);
        
        mriPath = Path.(subjects(s).name).mriPrepro.(segmentations{m});
        cfg.mri = load_mri_anytype(mriPath, PREPRO_VAR_NAME);

        submoduleName = sprintf("LOCALIZING SOURCES OF SUBJECT '%s' WITH MODEL '%s'", subjects(s).name, segmentations{m});
        finished(s,m) = run_submodule(@localize_source_BINO, cfg, submoduleName);
    end
end
