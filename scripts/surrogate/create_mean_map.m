% It is advised to not run the whole script automatically but to run
% 'Align maps' section first, check the 'finished' cell array if all maps
% were succesfully aligned and THEN run 'Create mean maps' section.

%% Init
clear variables
close all
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'S:\BP_MIDA'; % PC-MATOUS
Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote

Path.data.root = [Path.root '\data'];
Path.data.NUDZ = [Path.data.root '\MR'];
Path.data.BINO = [Path.data.root '\BINO'];
Path.output.root = [Path.root '\analysis'];
Path.output.NUDZ = [Path.output.root '\NUDZ'];
Path.output.BINO = [Path.output.root '\BINO'];

% dataset:
dataset = 'NUDZ';
%dataset = 'BINO';

ALIGNED = 'aligned2_ds2';

% common mri to align all maps to:
Path.mriTarget.NUDZ = '\\PC-matous\BP_MIDA\analysis\NUDZ\ANDROVICOVA_RENATA_8753138768\mri_common.mat';
Path.mriTarget.BINO = '\\PC-matous\BP_MIDA\analysis\BINO\S01\mri_common.mat';
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
for s = 1:nSubjects
    mriPrepro = Path.(subjects(s).name).mriPrepro;
    evals = Path.(subjects(s).name).surrogate.evals;
    nEvals = length(evals);
    for e = 1:nEvals
        evalPath = [evals(e).folder '\' evals(e).name];
        
        cfg = struct;
        cfg.downsample = 2;
        cfg.evaluation = [evalPath '\evaluation.mat'];
        cfg.mriPrepro = mriPrepro;
        cfg.mriTarget = Path.mriTarget.(dataset);
        cfg.sourcemodel = [evalPath '\simulationmodelDS.mat'];
        cfg.sourcemodelVarName = 'simulationmodelDS';
        
        cfg.output = [evalPath '\' ALIGNED];
        cfg.plot = true;
        cfg.visualize = false;
        cfg.visible = false;
        cfg.allowExistingFolder = false;
        
        submoduleName = sprintf("ALIGNING SUBJECT '%s' SIMULATION '%s'\n", subjects(s).name, evals(e).name);
        ret = run_submodule(@align_map, cfg, submoduleName);
        if ret
            finished(s,e) = 1;
        else
            finished(s,e) = -1;
        end
    end
end

%% Create mean maps
% Set manually: -----------------------------------------------------------
MAP_NAMES = {'ed1x' 'ed1y' 'ed1z' 'ed2x' 'ed2y' 'ed2z'};
nMapNames = length(MAP_NAMES);
fields = {'mean' 'std'};
nFields = length(fields);
evalName = cell(5,1);
evalName{1} = 'fieldtrip3_anatomy_prepro-fieldtrip3_anatomy_prepro_simulation';
evalName{2} = 'fieldtrip5_anatomy_prepro-fieldtrip5_anatomy_prepro_simulation';
evalName{3} = 'fieldtrip3_anatomy_prepro-mrtim12_simulation';
evalName{4} = 'fieldtrip5_anatomy_prepro-mrtim12_simulation';
evalName{5} = 'mrtim12-mrtim12_simulation';
% -------------------------------------------------------------------------
%% Run
for e = 1:length(evalName)
    mapNames = MAP_NAMES;
    nMapNames = length(mapNames);
    outputPath = [Path.root '\results\surrogate\' dataset '\' evalName{e}];
    [outputPath, imgPath] = create_output_folder(outputPath, false);
    map = struct;

    %% Gather aligned maps
    data = struct;
    for s = 1:nSubjects
        evalDir = [Path.(subjects(s).name).surrogate.root '\' evalName{e}];
        sourcePath = [evalDir '\' ALIGNED '\source_interp.mat'];
        source = load_var_from_mat('sourceInterp', sourcePath);

        if s == 1
            map.anatomy   = source.anatomy;
            %map.coordsys  = source.coordsys;
            map.dim       = source.dim;
            map.transform = source.transform;
            map.unit      = source.unit;

            for m = 1:nMapNames
                data.(mapNames{m}) = NaN([map.dim nSubjects]);
            end
        end

        if ~isequal(source.dim, map.dim)
            error("~isequal(source.dim, map.dim) for subject '%s'", subjects(s).name)
        end

        for m = 1:nMapNames
            source.(mapNames{m})(isnan(source.(mapNames{m}))) = 0;
            data.(mapNames{m})(:,:,:,s) = source.(mapNames{m});
        end
    end

    for m = 1:nMapNames
        if sum(isnan(data.(mapNames{m})))
            error("'data.%s' contains NaN values.", mapNames{m})
        end
    end

    %% Calculate Mean map and STD map
    for m = 1:nMapNames
        map.(mapNames{m})      = struct;
        map.(mapNames{m}).mean = mean(data.(mapNames{m}), 4);
        map.(mapNames{m}).std  = std(data.(mapNames{m}), 0, 4);
    end
    metrics = {'ed1', 'ed2'}; % Running out of memory.
    for m = 1:length(metrics)
        map.(metrics{m}) = struct;
        axisMetrics = {[metrics{m} 'x'], [metrics{m} 'y'], [metrics{m} 'z']};
        allAxis = NaN([map.dim, 3*nSubjects]);
        for a = 1:length(axisMetrics)
            allAxis(:,:,:,((a-1)*nSubjects) + 1 : a*nSubjects) = data.(axisMetrics{a});
        end
        if sum(isnan(allAxis))
            error("'allAxis' contains NaN values.")
        end
        map.(metrics{m}).mean = mean(cat(4, data.(axisMetrics{1}),data.(axisMetrics{2}),data.(axisMetrics{3})), 4);
        map.(metrics{m}).std  = std(cat(4, data.(axisMetrics{1}),data.(axisMetrics{2}),data.(axisMetrics{3})), 0, 4);
    end
    mapNames{end+1} = 'ed1';
    mapNames{end+1} = 'ed2';
    nMapNames = length(mapNames);
    save([outputPath '\mean_map'], 'map');

    %% Prepare plot config
    mriTarget = load_mri_anytype(Path.mriTarget.(dataset), MRI_TARGET_VAR_NAME);
    cfg = struct;
    cfg.crosshair = 'no'; % default
    cfg.location = 'center';
    cfg.parameter = 'tmp';
    cfg.mri = mriTarget;
    cfg.visible = false;
    cfg.visualize = false;

    for m = 1:nMapNames    
        for f = 1:nFields
            map.tmp = map.(mapNames{m}).(fields{f});
            cfg.name = ['slice_' mapNames{m} '_' fields{f}];
            cfg.save = [imgPath '\' cfg.name];
            plot_source(cfg, map);
        end
    end
    
    cfg.method = 'slice';
    for m = 1:nMapNames       
        for f = 1:nFields
            map.tmp = map.(mapNames{m}).(fields{f});
            cfg.name = ['slice_' mapNames{m} '_' fields{f}];
            cfg.save = [imgPath '\' cfg.name];
            plot_source(cfg, map);
        end
    end
    
    map = rmfield(map, 'tmp');
end

%% Calculate Differences (12-3)-(12-12) & (12-5)-(12-12)
% 'Path.root' and 'dataset' have to be initialized.
%
% 'Path.mriTarget.(dataset)' and 'MRI_TARGET_VAR_NAME' have to be
% initialized for plotting.
% Set manually: -----------------------------------------------------------
output = [Path.root '\results\surrogate\' dataset];

mapNames = {'ed1' 'ed2' 'ed1x' 'ed1y' 'ed1z' 'ed2x' 'ed2y' 'ed2z'};
nMapNames = length(mapNames);
fields = {'mean' 'std'};
nFields = length(fields);

abv = cell(1);
abv{1} = 'f3';
abv{2} = 'f5';
abv{3} = 'm12';
nAbv = length(abv);

Name = struct;
Name.(abv{1}) = 'fieldtrip3_anatomy_prepro-mrtim12_simulation';
Name.(abv{2}) = 'fieldtrip5_anatomy_prepro-mrtim12_simulation';
Name.(abv{3}) = 'mrtim12-mrtim12_simulation';
% -------------------------------------------------------------------------
%% Load Mean maps
Map = struct;
for a = 1:nAbv
    path = [output '\' Name.(abv{a}) '\mean_map.mat'];
    Map.(abv{a}) = load_var_from_mat('map', path);
end

%% Calculate Diff maps
for a = 1:2
    map = struct;
    map.anatomy   = Map.(abv{3}).anatomy;
    %map.coordsys  = Map.(abv{3}).coordsys;
    map.dim       = Map.(abv{3}).dim;
    map.transform = Map.(abv{3}).transform;
    map.unit      = Map.(abv{3}).unit;
    
    for m = 1:nMapNames
        map.(mapNames{m}) = struct;
        for f = 1:nFields
            map.(mapNames{m}).(fields{f}) = Map.(abv{a}).(mapNames{m}).(fields{f}) - Map.(abv{3}).(mapNames{m}).(fields{f});
        end
    end
    
    savePath = [output '\' abv{a} '-' abv{3}];
    [savePath, imgPath] = create_output_folder(savePath, false);
    save([savePath '\diff_map'], 'map');
    
    %% Prepare plot config
    mriTarget = load_mri_anytype(Path.mriTarget.(dataset), MRI_TARGET_VAR_NAME);
    cfg = struct;
    cfg.crosshair = 'no'; % default
    cfg.location = 'center';
    cfg.parameter = 'tmp';
    cfg.mri = mriTarget;
    cfg.visible = false;
    cfg.visualize = false;

    for m = 1:nMapNames 
        for f = 1:nFields
            map.tmp = map.(mapNames{m}).(fields{f});
            cfg.name = [mapNames{m} '_' fields{f}];
            cfg.save = [imgPath '\' cfg.name];
            plot_source(cfg, map);
        end
    end
    
    cfg.method = 'slice';
    for m = 1:nMapNames    
        for f = 1:nFields
            map.tmp = map.(mapNames{m}).(fields{f});
            cfg.name = ['slice_' mapNames{m} '_' fields{f}];
            cfg.save = [imgPath '\' cfg.name];
            plot_source(cfg, map);
        end
    end
    
    map = rmfield(map, 'tmp');
end
