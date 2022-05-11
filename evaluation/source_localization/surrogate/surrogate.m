function [evaluation, evaluationTable] = surrogate(Config)
% SURROGATE evaluates source-loaclization capability of a head model with
% generated white gaussian signal.
%
% Adapted code from ATiN RATESI Frontiers2021 project by Stanislav Jiricek.
% Matous Soldat, 2022
%
% Use as:
%   [evaluation, evaluationTable] = surrogate(Config)
%
% Required:
%   Config.output
%
%   Config.modelPath        = path to folder with files:
%                             sourcemodel.mat with var 'sourcemodel' / leadfield.mat with var 'leadfield'          
%                             headmodel.mat with var 'headmodel'
%                             elec.mat with var 'elec'
%    or
%   Config.sourcemodel
%   Config.headmodel
%   Config.elec (optional)
%   Config.leadfield (optional)
%
% Optional:
%   Config.simulationmodel  = Sourcemodel to simulate the activity with.
%                             By default, same model is used for simulation
%                             and localization.
%
%   Config.method           = cell array with one or more from {"eloreta", "lcmv"}
%                             default is {"eloreta"}
%
%   Config.dipoleDownsample = 1 (default) for no downsample,
%                             'x' for every 'x'th dipole (for each axis)
%
%   Config.keepMaps         = false (default)
%   Config.parallel         = true (default) to enable parallel computation
%   Config.verbose          = true (default) to display resultTable
%   Config.waitbar          = true (default) to show waitbar with ET
%   Config.allowExistingFolder = false (default)
%
%   Config.plot             = true (default)
%   Config.mri              = for plotting
%   Config.mriVarName       = if [Config.mri] is path to a '.mat' file
%
% Signal: TODO doc
%   Config.signal.snr       = Signal to Noise Ratio
%   Config.signal.T         = [s] signal duration
%   Config.signal.Tseg      = TODO not implemented, [s] duration of a signal segment
%   Config.signal.fs        = [Hz] Sampling Frequency
%   Config.signal.noisePower= [dBW] power of noise samples, specified as a scalar
%
% eLORETA defaults:
%   Config.eloreta.lambdas  = 0.05 for all SNRs
%                             

%% Constants
ELORETA = 'eloreta';
LCMV = 'lcmv';
SUPPORTED_METHODS = {ELORETA, LCMV};
METHOD = {ELORETA};
ELORETA_LAMBDA = 0.05;

AXES = {'x', 'y', 'z'};
DIPOLE_DOWNSAMPLE = 1; % 1 for no downsample, 'x' for every 'x'th dipole

SNR = 10; % Signal to Noise Ratio
T = 1; % [s] signal duration
%T_SEG = 1; % [s] duration of a signal segment % TODO not implemented
FS = 100; % [Hz] Sampling Frequency
NOISE_POWER = 10; % [dBW] Power of noise samples, specified as a scalar.

KEEP_MAPS = false;
PARALLEL = false;
PLOT = true;
VISUALIZE = true;
VERBOSE = true;
WAITBAR = true;
ALLOW_EXISTING_FOLDER = false;
MRI_VAR_NAME = 'mriPrepro';

%% Config - output
if ~isfield(Config, 'allowExistingFolder')
    Config.allowExistingFolder = ALLOW_EXISTING_FOLDER;
end
if isfield(Config, 'modelPath') && ~isfield(Config, 'output')
    Config.output = [Config.modelPath '\evaluation\surrogate'];
end
check_required_field(Config, 'output');
[output, imgPath] = create_output_folder(Config.output, Config.allowExistingFolder, true);

%% Config - Signal
if ~isfield(Config, 'signal')
    Config.signal.snr = SNR;
    Config.signal.T = T;
    %Config.signal.Tseg = T_SEG;
    Config.signal.fs = FS;
    Config.signal.noisePower = NOISE_POWER;
else
    if isfield(Config.signal, 'snr')
        if iscell(Config.signal.snr)
            Config.signal.snr = cell2mat(Config.signal.snr);
        end
    else
        Config.signal.snr = SNR;
    end
    if ~isfield(Config.signal, 'T')
        Config.signal.T = T;
    end
    %if ~isfield(Config.signal, 'Tseg')
    %    Config.signal.Tseg = T_SEG;
    %end
    if ~isfield(Config.signal, 'fs')
        Config.signal.fs = FS;
    end
    if ~isfield(Config.signal, 'noisePower')
        Config.signal.noisePower = NOISE_POWER;
    end
end
nSNR = length(Config.signal.snr);

%% Config - Method
if isfield(Config, 'method')
    Config.method = cellstr(Config.method);
else
    Config.method = METHOD;
end

if ~isfield(Config, 'dipoleDownsample')
    Config.dipoleDownsample = DIPOLE_DOWNSAMPLE;
end
if ismember(ELORETA, Config.method)
    if ~isfield(Config, 'eloreta') || ~isfield(Config.eloreta, 'lambdas')
        Config.eloreta.lambdas = NaN(1, nSNR);
        Config.eloreta.lambdas(:) = ELORETA_LAMBDA;
    end
end

%% Config - miscellaneous
if ~isfield(Config, 'keepMaps')
    Config.keepMaps = KEEP_MAPS;
end
if ~isfield(Config, 'parallel')
    Config.parallel = PARALLEL;
end
if ~isfield(Config, 'visualize')
    Config.visualize = VISUALIZE;
end
if ~isfield(Config, 'verbose')
    Config.verbose = VERBOSE;
end
if ~isfield(Config, 'waitbar')
    Config.waitbar = WAITBAR;
end

%% Load Model
if isfield(Config, 'modelPath')
    if isfile([Config.modelPath '\leadfield.mat'])
        load([Config.modelPath '\leadfield'], 'leadfield');
        check_required_field(leadfield, 'leadfield');
        sourcemodel = leadfield; clear leadfield
    elseif isfile([Config.modelPath '\sourcemodel.mat'])
        load([Config.modelPath '\sourcemodel'], 'sourcemodel');
        check_required_field(sourcemodel, 'leadfield');
    else
        error("Neither 'sourcemodel.mat' nor 'leadfield.mat' file found in '%s'.", Config.modelPath);
    end
    load([Config.modelPath '\headmodel'], 'headmodel');
    load([Config.modelPath '\elec'], 'elec');
    
else
    check_required_field(Config, 'sourcemodel');
    sourcemodel = Config.sourcemodel;
    check_required_field(sourcemodel, 'leadfield');
    check_required_field(Config, 'headmodel');
    headmodel = Config.headmodel;
    if ~isfield(Config, 'elec') && ~isfield(headmodel, 'elec')
        error("[Config] or [Config.headmodel] has to include field 'elec'.")
    end
    if isfield(Config, 'elec')
        elec = Config.elec;
    else
        elec = headmodel.elec;
    end
    if isfield(Config.leadfield)
        sourcemodel.leadfield = Config.leafield;
    end
    check_required_field(sourcemodel, 'leadfield');
end

if isfield(Config, 'simulationmodel')
    simulationmodel = convertStringsToChars(Config.simulationmodel);
    if ischar(simulationmodel)
        simulationmodel = load_var_from_mat('sourcemodel', simulationmodel);
    end
    check_required_field(simulationmodel, 'leadfield');
else
    simulationmodel = sourcemodel; % default
end
if ~isequal(simulationmodel.pos, sourcemodel.pos)
    error("'simulationmodel.pos' and 'sourcemodel.pos' have to be the same.")
end

%% Plot settings
plotAnatomy = isfield(Config, 'mri');
if plotAnatomy % test mri path
    if isfield(Config, 'mriVarName')
        mriVarName = Config.mriVarName;
    else
        mriVarName = MRI_VAR_NAME;
    end
    mri = load_mri_anytype(Config.mri, mriVarName);
    clear mri
end
if ~isfield(Config, 'plot')
    Config.plot = PLOT;
end

save([output '\config'], 'Config');

%% Init
method = Config.method;
dipoleDownsample = Config.dipoleDownsample;
if ismember(ELORETA, method)
    eloretaLambdas = Config.eloreta.lambdas;
end

SNR = Config.signal.snr;
SNRnames = generate_snr_names(SNR);
T = Config.signal.T;
%T_seg = Config.signal.Tseg;
fs = Config.signal.fs;
noisePower = Config.signal.noisePower;
t = 0 : 1/fs : T - 1/fs;

keepMaps = Config.keepMaps;
parallel = Config.parallel;
plot = Config.plot;
visualize = Config.visualize;
verbose = Config.verbose;
showBar = Config.waitbar;

[simulationmodelDS, keep] = downsample_sourcemodel(simulationmodel, dipoleDownsample);
save([output '\simulationmodelDS'], 'simulationmodelDS', 'keep');

dipoleIndexesDS = 1:length(simulationmodelDS.inside);
dipoleIndexesDS = dipoleIndexesDS(simulationmodelDS.inside(dipoleIndexesDS));
nIndexes = length(dipoleIndexesDS);

dipoleIndexes = 1:length(simulationmodel.inside);
dipoleIndexes = dipoleIndexes(keep);
dipoleIndexes = dipoleIndexes(simulationmodel.inside(dipoleIndexes));
if length(dipoleIndexes) ~= length(dipoleIndexesDS)
    error('length(dipoleIndexes) ~= length(dipoleIndexesDS)' )
end

method = check_methods(method, SUPPORTED_METHODS);
nMethod = length(method);

nAXES = length(AXES);

evaluation = struct;
evaluation.dipoleIndexes = make_column(dipoleIndexes);
evaluation.dipoleIndexesDS = make_column(dipoleIndexesDS);
for s = 1:nSNR
    for m = 1:nMethod
        evaluation.(method{m}).(SNRnames{s}).ed1 = NaN(nIndexes, nAXES);
        evaluation.(method{m}).(SNRnames{s}).ed2 = NaN(nIndexes, nAXES);
    end
end

if keepMaps
    sourceTemplate = get_source_template(sourcemodel);
    maps = struct;
    for s = 1:nSNR
        maps.truth.(SNRnames{s}) = cell(nIndexes, 1);
        for m = 1:nMethod
            maps.(method{m}).(SNRnames{s}) = cell(nIndexes, nAXES);
        end
    end
end

%% Run
if showBar
    bar = 0;
    barMax = nSNR * nIndexes;
    figBar = waitbar(bar/barMax, {['Computed: 0 / ' num2str(barMax)], 'Estimated Time Remaining: TBD'},...
        'Name', 'Surrogate Source Localization');
end

for s = 1:nSNR
    for d = 1:nIndexes
        if showBar
            iterationStart = tic;
        end
        
        %% Simualte signal
        signal = wgn(1, T*fs, noisePower);
        if keepMaps
            sourcemap = sourceTemplate;
            sourcemap(dipoleIndexes(d)) = sqrt(sum(signal.^2));
            maps.truth.(SNRnames{s}){d} = sourcemap;
        end
        
        dipoleLeadfield = simulationmodel.leadfield{1, dipoleIndexes(d)};
        potencial = struct;
        for a = 1:nAXES
            potencial.(AXES{a}) = dipoleLeadfield(:,a)*signal;
            potencial.(AXES{a}) = awgn(potencial.(AXES{a}), SNR(s), 'measured');
        end
        
        %% FieldTrip structure
        dataStruct          = struct;
        dataStruct.label    = elec.label;
        dataStruct.fsample  = fs;
        for a = 1:nAXES
            dataStruct.trial{a} = potencial.(AXES{a});
            dataStruct.time{a}  = t;
        end
        % TODO ? separate data to shorter sections with 'ft_redefinetrial'
        
        %% Source Analysis - Prepro
        %% Preprocess
        data = struct;
        cfg = struct;
        cfg.demean = 'yes';
        for a = 1:nAXES
            trials = [0 0 0];
            trials(a) = 1;
            cfg.trials = logical(trials);
            data.(AXES{a}) = ft_preprocessing(cfg, dataStruct); % TODO read doc
        end
        
        %% Covariance Matrix
        cfg                  = [];
        cfg.covariance       = 'yes';
        cfg.covariancewindow = 'all';
        cfg.keeptrials       = 'no';
        cfg.vartrllength     = 2;
        timelock = cell(nAXES, 1);
        
        
        for a = 1:nAXES
            timelock{a} = ft_timelockanalysis(cfg, data.(AXES{a})); % TODO read doc
        end
        
        %% Source Analysis - Solve
        source = struct;        
        %% LCMV (Linear Constrained Minimal Variance) % ! NOT TESTED, NOT OPTIMIZED
        if ismember(LCMV, method)
            lcmvLambdas = NaN(1, nAXES);
            for a = 1:nAXES
                lcmvLambdas(a) = 0.003*max(eig(timelock{a}.cov)); % TODO study
            end
            
            cfg                   = struct;
            cfg.method            = 'lcmv';
            cfg.sourcemodel       = sourcemodel;
            cfg.headmodel         = headmodel;
            cfg.lcmv.projectnoise = 'yes';
            cfg.elec              = elec;
            cfg.lcmv.keepfilter   = 'no';
            cfg.lcmv.keepcov      = 'yes';
            cfg.lcmv.keepmom      = 'no';

            if parallel
                cfgAnalysis = cell(nAXES, 1);
                for a = 1:nAXES
                    cfgAnalysis{a} = cfg;
                    cfg.lcmv.lambda = lcmvLambdas(a);
                end
                sourceAnalysis = cell(nAXES, 1);
                parfor a = 1:nAXES
                    sourceAnalysis{a} = ft_sourceanalysis(cfgAnalysis{a}, timelock{a});
                end
                for a = 1:nAXES
                    source.(LCMV).(AXES{a}) = sourceAnalysis{a};
                    source.(LCMV).(AXES{a}).avg.nai = source.(LCMV).(AXES{a}).avg.pow ./ source.(LCMV).(AXES{a}).avg.noise;
                    if keepMaps
                        maps.(LCMV).(SNRnames{s}){d,a} = source.(LCMV).(AXES{a}).avg.nai;
                    end
                end
                clear sourceAnalysis
            else
                for a = 1:nAXES
                    cfg.lcmv.lambda = lcmvLambdas(a);
                    source.(LCMV).(AXES{a}) = ft_sourceanalysis(cfg, timelock{a}); % TODO read doc
                    source.(LCMV).(AXES{a}).avg.nai = source.(LCMV).(AXES{a}).avg.pow ./ source.(LCMV).(AXES{a}).avg.noise;
                    if keepMaps
                        maps.(LCMV).(SNRnames{s}){d,a} = source.(LCMV).(AXES{a}).avg.nai;
                    end
                end
            end
        end
        
        %% eLORETA
        if ismember(ELORETA, method)
            eLoretaCfg                    = struct;
            eLoretaCfg.method             = 'eloreta';
            eLoretaCfg.sourcemodel        = sourcemodel;
            eLoretaCfg.headmodel          = headmodel;
            eLoretaCfg.elec               = elec;
            eLoretaCfg.eloreta.keepfilter = 'no';
            eLoretaCfg.eloreta.keepmom    = 'no';
            eLoretaCfg.eloreta.lambda     = eloretaLambdas(s);
            if ~isfield(sourcemodel, 'filter')
                eLoretaCfg.eloreta.keepfilter = 'yes';
            end
            
            if parallel
                sourceAnalysis = cell(nAXES, 1);
                parfor a = 1:nAXES
                    sourceAnalysis{a} = ft_sourceanalysis(eLoretaCfg, timelock{a});
                end
                for a = 1:nAXES
                    source.(ELORETA).(AXES{a}) = sourceAnalysis{a};
                    if keepMaps
                        maps.(ELORETA).(SNRnames{s}){d,a} = source.(ELORETA).(AXES{a}).avg.pow;
                    end
                end
                clear sourceAnalysis
            else
                for a = 1:nAXES
                    source.(ELORETA).(AXES{a}) = ft_sourceanalysis(eLoretaCfg, timelock{a});
                    if keepMaps
                        maps.(ELORETA).(SNRnames{s}){d,a} = source.(ELORETA).(AXES{a}).avg.pow;
                    end
                end
            end
            
            if ~isfield(sourcemodel, 'filter')
                sourcemodel.filter = source.(ELORETA).(AXES{1}).avg.filter;
            end
        end
        
        %% Metrics
        valueParameter.default = 'pow';
        valueParameter.(LCMV) = 'nai';
        %% ED1
        cfg = struct;
        cfg.dipoleIdx = dipoleIndexes(d);
        cfg.sourcemodel = sourcemodel;
        cfg.returnOne = true;
        for m = 1:nMethod
            param = choose_value_parameter(valueParameter, method{m});
            for a = 1:nAXES
                cfg.dipoleValues = source.(method{m}).(AXES{a}).avg.(param);
                evaluation.(method{m}).(SNRnames{s}).ed1(d,a) = ed1(cfg);
            end
        end
        
        %% ED2
        cfg = struct;
        cfg.sourcemodel = sourcemodel;
        cfg.dipoleIdx = dipoleIndexes(d);
        for m = 1:nMethod
            param = choose_value_parameter(valueParameter, method{m});
            for a = 1:nAXES
                cfg.dipoleValues = source.(method{m}).(AXES{a}).avg.(param);
                evaluation.(method{m}).(SNRnames{s}).ed2(d,a) = ed2(cfg);
            end
        end
        
        %% Update waitbar
        if showBar
            time = toc(iterationStart);
            bar = bar + 1;
            estimated_time = (time * (barMax - bar)) / 60; % [min]
            waitbar(bar/barMax, figBar, {['Computed: ' num2str(bar) ' / ' num2str(barMax)], ['Estimated Time Remaining: ' num2str(estimated_time) ' min']});
        end
    end
end
if showBar
    close(figBar)
end

%% Evaluate & Save
for m = 1:nMethod
    for s = 1:nSNR 
        evaluation.(method{m}).(SNRnames{s}).ed1mean = mean(evaluation.(method{m}).(SNRnames{s}).ed1, 1, 'omitnan');
        evaluation.(method{m}).(SNRnames{s}).ed1std = std(evaluation.(method{m}).(SNRnames{s}).ed1, 0, 1, 'omitnan');
        evaluation.(method{m}).(SNRnames{s}).ed2mean = mean(evaluation.(method{m}).(SNRnames{s}).ed2, 'all', 'omitnan');
        evaluation.(method{m}).(SNRnames{s}).ed2std = std(evaluation.(method{m}).(SNRnames{s}).ed2, 0, 'all', 'omitnan');
    end
end
save([output '\evaluation'], 'evaluation');
if keepMaps
    save([output '\maps'], 'maps');
end

%% Plot Results in Table
cfg = struct;
cfg.method = method;
cfg.SNR = SNR;
cfg.SNRnames = SNRnames;
cfg.verbose = verbose;
cfg.save = [output '\evaluation_table'];
evaluationTable = plot_evaluation_table(cfg, evaluation);

%% Plot Results on MRI
if ~plot
    return
end

if plotAnatomy
    mri = load_mri_anytype(Config.mri, mriVarName);
end
index = {'ed1', 'ed2'};
for i = 1:length(index)
    for m = 1:nMethod
        for s = 1:nSNR
            for a = 1:nAXES
                %%
                indexValues = evaluation.(method{m}).(SNRnames{s}).(index{i});
                indexMap = zeros(length(simulationmodelDS.inside), 1);
                indexMap(dipoleIndexesDS) = indexValues(:,a);
                %%
                sourcePlot = struct;
                sourcePlot.dim = simulationmodelDS.dim;
                sourcePlot.pos = simulationmodelDS.pos;
                sourcePlot.unit = simulationmodelDS.unit;
                sourcePlot.(index{i}) = indexMap;
                %%
                name = sprintf('%s_%s_%s_%s', index{i}, method{m}, SNRnames{s}, AXES{a});
                cfg = struct;
                cfg.parameter = index{i};
                cfg.crosshair = 'no'; % default
                cfg.location = 'center';
                if plotAnatomy
                    cfg.mri = mri;
                end
                cfg.name = [name '_interp'];
                cfg.save = [imgPath '\' cfg.name];
                cfg.visualize = visualize;
                plot_source(cfg, sourcePlot);
                %%
                sourcePlot.inside = simulationmodelDS.inside;
                %%
                cfg.name = name;
                cfg.save = [imgPath '\' cfg.name];
                plot_source(cfg, sourcePlot);
            end
        end
    end
end
end
