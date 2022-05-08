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
%   Config.method           = cell array with one or more from {"eloreta", "lcmv"}
%                             default is {"eloreta"}
%
%   Config.dipoleDownsample = 1 (default) for no downsample,
%                             'x' for every 'x'th dipole
%
%   Config.parallel         = true (default) to enable parallel computation
%   Config.verbose          = true (default) to display resultTable
%   Config.waitbar          = true (default) to show waitbar with ET
%   Config.allowExistingFolder = false (defaults)
%
% Signal: TODO doc
%   Config.signal.snr       = Signal to Noise Ratio
%   Config.signal.T         = [s] signal duration
%   Config.signal.Tseg      = TODO not implemented, [s] duration of a signal segment
%   Config.signal.fs        = [Hz] Sampling Frequency
%   Config.signal.noisePower= [dBW] power of noise samples, specified as a scalar
%
% eLORETA defaults:
%   Config.eloreta.lambdas  = [10753.1834949415	0.257843673057386	0.0739440420798500	0.00769461295275684];
%                             

%% Constants
ELORETA = 'eloreta';
LCMV = 'lcmv';
SUPPORTED_METHODS = {ELORETA, LCMV};
METHOD = {ELORETA};

AXES = {'x', 'y', 'z'};
DIPOLE_DOWNSAMPLE = 1; % 1 for no downsample, 'x' for every 'x'th dipole
ELORETA_SUPPORTED_SNR = [5 10 15 25]; % each SNR needs a lambda
ELORETA_LAMBDAS = [10753.1834949415, 0.257843673057386, 0.0739440420798500, 0.00769461295275684];

SNR = 10; % Signal to Noise Ratio
T = 1; % [s] signal duration
%T_SEG = 1; % [s] duration of a signal segment % TODO not implemented
FS = 100; % [Hz] Sampling Frequency
NOISE_POWER = 10; % [dBW] Power of noise samples, specified as a scalar.

PARALLEL = false;
VERBOSE = true;
WAITBAR = true;
ALLOW_EXISTING_FOLDER = false;

%% Config - output
if ~isfield(Config, 'allowExistingFolder')
    Config.allowExistingFolder = ALLOW_EXISTING_FOLDER;
end
check_required_field(Config, 'output');
[output, ~] = create_output_folder(Config.output, Config.allowExistingFolder, false);

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
        for s = 1:length(Config.signal.snr)
            if ~ismember(Config.signal.snr(s), ELORETA_SUPPORTED_SNR)
                error("Default eLORETA lambdas are only defined for SNR = [5, 10, 15, 25]. Choose one of default SNRs or define eLORETA lambdas for each used SNR (in the same order) in 'Config.eloreta.lambdas'.")
            else
                Config.eloreta.lambdas(s) = ELORETA_LAMBDAS(Config.signal.snr(s) == ELORETA_SUPPORTED_SNR);
            end
        end
    end
end

%% Config - miscellaneous
if ~isfield(Config, 'parallel')
    Config.parallel = PARALLEL;
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

    if ~isfield(Config, 'output')
        Config.output = [Config.modelPath '\evaluation\surrogate'];
    end
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

%% Init
method = Config.method;
dipoleDownsample = Config.dipoleDownsample;
if ismember(ELORETA, method)
    eloretaLambdas = Config.eloreta.lambdas;
end
SNR = Config.signal.snr;
T = Config.signal.T;
%T_seg = Config.signal.Tseg;
fs = Config.signal.fs;
noisePower = Config.signal.noisePower;
verbose = Config.verbose;
showBar = Config.waitbar;

dipoleIndexes = 1:dipoleDownsample:length(sourcemodel.inside);
dipoleIndexes = dipoleIndexes(sourcemodel.inside(dipoleIndexes));
nDipoleIndexes = length(dipoleIndexes);

method = check_methods(method, SUPPORTED_METHODS);
nMethod = length(method);

SNRnames = generate_snr_names(SNR);
nSNR = length(SNR);

nAXES = length(AXES);

t = 0 : 1/fs : T - 1/fs;

computationData = struct;
computationData.eloreta = struct;
computationData.lcmv = struct;
computationData.sourceTemplate = get_source_template(sourcemodel);

% TODO make evaluation init into a function
evaluation = struct;
evaluation.dipoleIndexes = make_column(dipoleIndexes);
for s = 1:nSNR
    evaluation.truthMaps.(SNRnames{s}).maps = cell(nDipoleIndexes, 1);
    for m = 1:nMethod
        evaluation.(method{m}).(SNRnames{s}).maps = cell(nDipoleIndexes, nAXES);
        evaluation.(method{m}).(SNRnames{s}).ed1 = NaN(nDipoleIndexes, nAXES);
        evaluation.(method{m}).(SNRnames{s}).ed2 = NaN(nDipoleIndexes, nAXES);
    end
end

%% Run
if showBar
    bar = 0;
    barMax = nSNR * nDipoleIndexes;
    figBar = waitbar(bar/barMax, {['Computed: 0 / ' num2str(barMax)], 'Estimated Time Remaining: TBD'},...
        'Name', 'Surrogate Source Localization');
end

for s = 1:nSNR
    for d = 1:nDipoleIndexes
        if showBar
            iterationStart = tic;
        end
        
        %% Simualte signal
        signal = wgn(1, T*fs, noisePower);
        sourcemap = computationData.sourceTemplate;
        sourcemap(dipoleIndexes(d)) = sqrt(sum(signal.^2));
        evaluation.truthMaps.(SNRnames{s}).maps{d} = sourcemap;
        
        dipoleLeadfield = sourcemodel.leadfield{1, dipoleIndexes(d)};
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
        lcmvLambdas = NaN(1, nAXES);
        for a = 1:nAXES
            timelock{a} = ft_timelockanalysis(cfg, data.(AXES{a})); % TODO read doc
            lcmvLambdas(a) = 0.003*max(eig(timelock{a}.cov)); % TODO study
        end
        
        %% Source Analysis - Solve
        source = struct;        
        %% LCMV (Linear Constrained Minimal Variance) % ! NOT TESTED, NOT OPTIMIZED
        if ismember(LCMV, method)
            cfg                   = struct;
            cfg.method            = 'lcmv';
            cfg.sourcemodel       = sourcemodel;
            cfg.headmodel         = headmodel;
            cfg.lcmv.projectnoise = 'yes';
            cfg.elec              = elec;
            cfg.lcmv.keepfilter   = 'no';
            cfg.lcmv.keepcov      = 'yes';
            cfg.lcmv.keepmom      = 'no';

            if Config.parallel
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
                    evaluation.(LCMV).(SNRnames{s}).maps{d,a} = source.(LCMV).(AXES{a}).avg.nai;
                end
                clear sourceAnalysis
            else
                for a = 1:nAXES
                    cfg.lcmv.lambda = lcmvLambdas(a);
                    source.(LCMV).(AXES{a}) = ft_sourceanalysis(cfg, timelock{a}); % TODO read doc
                    source.(LCMV).(AXES{a}).avg.nai = source.(LCMV).(AXES{a}).avg.pow ./ source.(LCMV).(AXES{a}).avg.noise;
                    evaluation.(LCMV).(SNRnames{s}).maps{d,a} = source.(LCMV).(AXES{a}).avg.nai;
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
            if isfield(computationData.eloreta, 'filter')
                eLoretaCfg.eloreta.filter = computationData.eloreta.filter;
            else
                eLoretaCfg.eloreta.keepfilter = 'yes';
            end
            
            if Config.parallel
                sourceAnalysis = cell(nAXES, 1);
                parfor a = 1:nAXES
                    sourceAnalysis{a} = ft_sourceanalysis(eLoretaCfg, timelock{a});
                end
                for a = 1:nAXES
                    source.(ELORETA).(AXES{a}) = sourceAnalysis{a};
                    evaluation.(ELORETA).(SNRnames{s}).maps{d,a} = source.(ELORETA).(AXES{a}).avg.pow;
                end
                clear sourceAnalysis
            else
                for a = 1:nAXES
                    source.(ELORETA).(AXES{a}) = ft_sourceanalysis(eLoretaCfg, timelock{a});
                    source.(ELORETA).(AXES{a}).avg.pow = source.(ELORETA).(AXES{a}).avg.pow'; % TODO
                    evaluation.(ELORETA).(SNRnames{s}).maps{d,a} = source.(ELORETA).(AXES{a}).avg.pow;
                end
            end
            
            if ~isfield(computationData.eloreta, 'filter')
                computationData.eloreta.filter = source.(ELORETA).(AXES{1}).avg.filter;
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
        % TODO test no 'omitnan'
        evaluation.(method{m}).(SNRnames{s}).ed1mean = mean(evaluation.(method{m}).(SNRnames{s}).ed1, 1, 'omitnan');
        evaluation.(method{m}).(SNRnames{s}).ed1std = std(evaluation.(method{m}).(SNRnames{s}).ed1, 0, 1, 'omitnan');
        evaluation.(method{m}).(SNRnames{s}).ed2mean = mean(evaluation.(method{m}).(SNRnames{s}).ed2, 'all', 'omitnan');
        evaluation.(method{m}).(SNRnames{s}).ed2std = std(evaluation.(method{m}).(SNRnames{s}).ed2, 0, 'all', 'omitnan');
    end
end
save([output '\evaluation'], 'evaluation');

%% Plot Results in Table
cfg = struct;
cfg.method = method;
cfg.SNR = SNR;
cfg.SNRnames = SNRnames;
cfg.verbose = verbose;
cfg.save = [output '\evaluation_table'];
evaluationTable = plot_evaluation_table(cfg, evaluation);
end
