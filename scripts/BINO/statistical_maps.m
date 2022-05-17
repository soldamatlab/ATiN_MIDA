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

ALIGNED = 'aligned2_keepinside_ds2';

evals = cell(1);
evals{1} = 'fieldtrip3_anatomy_prepro';
evals{2} = 'fieldtrip5_anatomy_prepro';
evals{3} = 'mrtim12';
nEvals = length(evals);

names = cell(1);
names{1} = 'f3';
names{2} = 'f5';
names{3} = 'm12';
if length(names) ~= nEvals
    error("length(fields) ~= length(evals)")
end

fields = cell(1);
fields{1} = 'houses';
fields{2} = 'faces';
nFields = length(fields);

output = '\\PC-matous\BP_MIDA\results\stimulation\BINO';


%% Get subject paths
subjects = dir([Path.output.BINO '\S*']);
nSubjects = length(subjects);
for s = 1:nSubjects
    Path.(subjects(s).name).root = [subjects(s).folder '\' subjects(s).name];
    Path.(subjects(s).name).stimulation.root =...
        [Path.(subjects(s).name).root '\evaluation\stimulation'];
    for e = 1:nEvals
        Path.(subjects(s).name).stimulation.(names{e}) = [Path.(subjects(s).name).stimulation.root '\' evals{e} '\' ALIGNED '\source_interp.mat'];
    end
end

%% Statistical maps
for e = 1:nEvals
    %% Load subject sources
    evalOutput = create_output_folder([output '\' evals{e}], false, false);
    
    sources = cell(nSubjects, 1);
    sourcesAvg = cell(nSubjects, 1);
    for  s = 1:nSubjects
        sources{s} = load_var_from_mat('sourceInterp', Path.(subjects(s).name).stimulation.(names{e}));
        sourcesAvg{s} = sources{s};
        for f = 1:nFields
            map = sources{s}.(fields{f});
            inside = sourcesAvg{s}.inside;
            map(inside) = mean(map(inside), 'all');
            % TODO ? set non-inside to 0 / NaN
            sourcesAvg{s}.(fields{f}) = map;
        end
    end
    
    %% Calculate statistical maps
    for f = 1:nFields
        %%
        cfg = [];    
        cfg.parameter = fields{f}; 
        cfg.method = 'montecarlo';
        cfg.statistic = 'ft_statfun_depsamplesT';
        cfg.clusterstatistic = 'maxsum';
        cfg.clusterthreshold = 'parametric';
        cfg.numrandomization = 2000;
        cfg.tail         = 0;
        cfg.alpha        = 0.05;
        cfg.clusteralpha = 0.05;
        cfg.clustertail  = 0;
        cfg.correctm     = 'cluster';
        cfg.design(1,:) = [1:nSubjects 1:nSubjects];
        cfg.design(2,:) = [ones(1,nSubjects) 2*ones(1,nSubjects)];
        cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
        cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)
        [stat] = ft_sourcestatistics(cfg, sources{:}, sourcesAvg{:});

        save([evalOutput '\stat_map_' fields{f}], 'stat')
    end
end
