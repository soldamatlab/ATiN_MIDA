%% Init
clear variables
close all
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data'; % NTB
%Path.root = 'S:\BP_MIDA'; % PC-MATOUS
Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote
%Path.root = 'S:\matous'; % PC-SIMON

Path.data.root = [Path.root '\data'];
Path.data.NUDZ = [Path.data.root '\MR'];
Path.data.BINO = [Path.data.root '\BINO'];
Path.output.root = [Path.root '\analysis'];
Path.output.NUDZ = [Path.output.root '\NUDZ'];
Path.output.BINO = [Path.output.root '\BINO'];

% dataset:
dataset = 'NUDZ';
%dataset = 'BINO';

% common mri to align all maps to:
Path.mriTarget.NUDZ = '\\PC-matous\BP_MIDA\analysis\NUDZ\ANDROVICOVA_RENATA_8753138768\mri_common.mat';
Path.mriTarget.BINO = ''; % TODO
MRI_TARGET_VAR_NAME = 'mriCommon';

%% Get subject paths
if strcmp(dataset, 'NUDZ')
    subjects = dir([Path.output.NUDZ '\*_*_*']);
elseif strcmp(dataset, 'BINO')
    subjects = dir([Path.output.BINO '\S*']);
else
    error("Unknown dataset")
end
nSubjects = length(subjects);
for s = 1:nSubjects
    Path.(subjects(s).name).surrogate.root =...
        [subjects(s).folder '\' subjects(s).name '\evaluation\surrogate'];
    Path.(subjects(s).name).mriPrepro =...
        [subjects(s).folder '\' subjects(s).name '\segmentation\mrtim12\anatomy_prepro.nii'];
    
    Path.(subjects(s).name).surrogate.evals = dir([Path.(subjects(s).name).surrogate.root '\*-*_simulation']);
end

%% Align maps
finished = [];
for s = 3:nSubjects
    mriPrepro = Path.(subjects(s).name).mriPrepro;
    evals = Path.(subjects(s).name).surrogate.evals;
    nEvals = length(evals);
    for e = 1:nEvals
        evalPath = [evals(e).folder '\' evals(e).name];
        
        cfg = struct;
        cfg.evaluation = [evalPath '\evaluation.mat'];
        cfg.mriPrepro = mriPrepro;
        cfg.mriTarget = Path.mriTarget.(dataset);
        cfg.sourcemodel = [evalPath '\simulationmodelDS.mat'];
        cfg.sourcemodelVarName = 'simulationmodelDS';
        
        cfg.output = [evalPath '\aligned'];
        cfg.plot = true;
        cfg.visualize = false;
        cfg.allowExistingFolder = true;
        
        submoduleName = sprintf("ALIGNING SUBJECT '%s' SIMULATION '%s'\n", subjects(s).name, evals(e).name);
        ret = run_submodule(@align_map, cfg, submoduleName);
        if ret
            finished(s,e) = 1;
        else
            finished(s,e) = -1;
        end
    end
end
