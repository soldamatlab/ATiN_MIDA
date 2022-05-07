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

%% Get paths to models
methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);
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
        Path.(subjects(s).name).sourcemodel.(segmentations{m}) =...
            [subjects(s).folder '\' subjects(s).name '\model\' segmentations{m} '\' sourcemodelFileName];
    end
end

%% Prepare models
cfg = struct;
cfg.method = 'eloreta';
SNR = [5, 10, 15, 25];
cfg.dipoleDownsample = 1;

finished = NaN(nSubjects, nSegmentations);
for s = 1:nSubjects
    for r = 1:length(SNR)
        cfg.signal.snr = SNR(r);
        for m = 1:nSegmentations
            cfg.modelPath = Path.(subjects(s).name).sourcemodel.(segmentations{m});
            cfg.output = [cfg.modelPath '\..\..\evaluation\surrogate'];

            submoduleName = sprintf("EVALUATING SUBJECT '%s' MODEL '%s' with SNR = '%d' dB\n", subjects(s).name, segmentations{m}, SNR(r));
            finished(s,m) = run_submodule(@surrogate, cfg, submoduleName);
        end
    end
end
