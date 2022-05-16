%% Init
clear variables
close all
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'S:\BP_MIDA'; % PC-MATOUS
Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote

Path.data.root = [Path.root '\data'];
Path.data.BINO = [Path.data.root '\BINO'];
Path.output.root = [Path.root '\analysis'];
Path.output.BINO = [Path.output.root '\BINO'];

% common mri to align all maps to:
Path.mriTarget = '\\PC-matous\BP_MIDA\analysis\BINO\S01\mri_common.mat';
MRI_TARGET_VAR_NAME = 'mriCommon';

evals = cell(1);
evals{1} = 'fieldtrip3_anatomy_prepro';
evals{2} = 'fieldtrip5_anatomy_prepro';
evals{3} = 'mrtim12';
nEvals = length(evals);

fields = cell(1);
fields{1} = 'f3';
fields{2} = 'f5';
fields{3} = 'm12';
if length(fields) ~= nEvals
    error("length(fields) ~= length(evals)")
end

%% Get subject paths
subjects = dir([Path.output.BINO '\S*']);
nSubjects = length(subjects);
for s = 1:nSubjects
    Path.(subjects(s).name).root = [subjects(s).folder '\' subjects(s).name];
    Path.(subjects(s).name).stimulation.root =...
        [Path.(subjects(s).name).root '\evaluation\stimulation'];
    Path.(subjects(s).name).sourcemodel.root =...
        [Path.(subjects(s).name).root '\model'];
    
    for e = 1:nEvals
        Path.(subjects(s).name).stimulation.(fields{e}) = [Path.(subjects(s).name).stimulation.root '\' evals{e}];
        Path.(subjects(s).name).sourcemodel.(fields{e}) = [Path.(subjects(s).name).sourcemodel.root '\' evals{e} '\sourcemodel.mat'];
    end
    
    Path.(subjects(s).name).mriPrepro =...
        [subjects(s).folder '\' subjects(s).name '\segmentation\mrtim12\anatomy_prepro.nii'];
end

%% Align sources
finished = [];
for s = 1:nSubjects
    mriPrepro = Path.(subjects(s).name).mriPrepro;
    for e = 1:nEvals
        evalPath = Path.(subjects(s).name).stimulation.(fields{e});
        
        cfg = struct;
        cfg.binosim = true;
        cfg.keepinside = true;
        cfg.evaluation = [evalPath '\evaluation.mat'];
        cfg.mriPrepro = mriPrepro;
        cfg.mriTarget = Path.mriTarget;
        cfg.sourcemodel = Path.(subjects(s).name).sourcemodel.(fields{e});
        
        cfg.output = [evalPath '\aligned_keepinside'];
        cfg.plot = true;
        cfg.visualize = false;
        cfg.visible = false;
        cfg.allowExistingFolder = false;
        
        submoduleName = sprintf("ALIGNING SUBJECT '%s' EVALUATION '%s'\n", subjects(s).name, evals{e});
        ret = run_submodule(@align_map, cfg, submoduleName);
        if ret
            finished(s,e) = 1;
        else
            finished(s,e) = -1;
        end
    end
end
