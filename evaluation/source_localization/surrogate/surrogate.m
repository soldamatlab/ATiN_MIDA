%% Init
clear variables
close all

%% Define source code paths
wd = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project\evaluation\source_localization\surrogate'; 
constPath = [wd '\..\..\..\common\const'];
addpath(genpath(wd));
addpath(constPath);
const_path; % initiates structure 'Path'
addpath(Path.source.common);

%% Init FieldTrip
addpath(Path.toolbox.fieldtrip)
ft_defaults

%% Constants & Settings
ELORETA = "eloreta";
LCMV = "lcmv";
SUPPORTED_METHODS = [ELORETA, LCMV];
method = [ELORETA, LCMV]; % choose one or more from 'SUPPORTED_METHODS'

dipoleDownsample = 64; % 1 for no downsample, 'x' for every 'x'th dipole
eloretaLambdas = [10753.1834949415	0.257843673057386	0.0739440420798500	0.00769461295275684];

modelPath = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\out\model_fieldtrip_test\03'; % TODO
outputPath = [modelPath '\evaluation\surrogate'];

%% Define Signal TODO
SNR     = [5, 25]; % [dB] Signal-to-Noise Ratio, choose multiple by [5 10 15 25]
T       = 1; % délka signálu v sekundách
T_seg   = 1; % délka segmentu
fs      = 100; % vzorkovací frekvence v Hz
t       = 0:1/fs:T-1/fs; % časová vektor signálu

noisePower = 10; % [dBW] Power of noise samples, specified as a scalar.

%% Load Data
load([modelPath '\leadfield'], 'leadfield');
%sourcemodel = remove_leadfield(leadfield);
%leadfield = leadfield.leadfield;
sourcemodel = leadfield; clear leadfield
load([modelPath '\headmodel'], 'headmodel');
load([modelPath '\elec'], 'elec');

%% Init
method = check_methods(method, SUPPORTED_METHODS);
nMethod = length(method);
nSNR = length(SNR);
sourceTemplate = get_source_template(sourcemodel);
nDipoles = length(sourcemodel.pos);
[outputPath, imgPath] = create_output_folder(outputPath);

% TODO make evaluation init into a function
evaluation = struct;
for m = 1:nMethod
    evaluation.(method(m)).maps = {};
    for s = 1:nSNR
        evaluation.(method(m)).maps{s} = [];
    end
    evaluation.(method(m)).ed1 = zeros(nSNR, 3, nDipoles);
end

%% Run
bar = 0;
bar_max = nSNR * sum(sourcemodel.inside(1:dipoleDownsample:nDipoles));
fig = waitbar(0, {['Computed: 0 / ' num2str(bar_max)], 'Estimated Time Remaining: TBD'},...
    'Name', 'Surrogate Source Localization');

for s = 1:nSNR
    for d = 1:dipoleDownsample:nDipoles
        if sourcemodel.inside(d) == 0
            continue
        end
        iterationStart = tic;
        
        %% Simualte signal
        signal = wgn(1, T*fs, noisePower);
        sourcemap = sourceTemplate;
        sourcemap(d) = sqrt(sum(signal.^2));
        
        dipoleLeadfield = sourcemodel.leadfield{1,d};
        potencialX = dipoleLeadfield(:,1)*signal;
        potencialY = dipoleLeadfield(:,2)*signal;
        potencialZ = dipoleLeadfield(:,3)*signal;
        PotencialX = awgn(potencialX, SNR(s), 'measured');
        PotencialY = awgn(potencialY, SNR(s), 'measured');
        PotencialZ = awgn(potencialZ, SNR(s), 'measured');
        
        %% FieldTrip structure
        data          = [];
        data.label    = elec.label;
        data.fsample  = fs;
        data.trial{1} = potencialX;
        data.time{1}  = t;
        data.trial{2} = potencialY;
        data.time{2}  = t;
        data.trial{3} = potencialZ;
        data.time{3}  = t;
        
        % TODO ? separate data to shorter sections with 'ft_redefinetrial'
        
        %% Preprocess
        cfg = struct;
        cfg.demean = 'yes';
        
        cfg.trials = logical([1 0 0]);
        dataX = ft_preprocessing(cfg, data); % TODO read doc
        
        cfg.trials = logical([0 1 0]);
        dataY = ft_preprocessing(cfg, data);
        
        cfg.trials = logical([0 0 1]);
        dataZ = ft_preprocessing(cfg, data);
        
        %% Covariance Matrix
        cfg                  = [];
        cfg.covariance       = 'yes';
        cfg.covariancewindow = 'all';
        cfg.keeptrials       = 'no';
        cfg.vartrllength     = 2; % TODO 'vartrllength' not in doc
        timelockX = ft_timelockanalysis(cfg, dataX); % TODO read doc
        timelockY = ft_timelockanalysis(cfg, dataY);
        timelockZ = ft_timelockanalysis(cfg, dataZ);
        
        % TODO study:
        lcmvLambdas = [0.003*max(eig(timelockX.cov)) 0.003*max(eig(timelockY.cov)) 0.003*max(eig(timelockZ.cov))];
        
        %% Source Analysis
        source = struct;
        %% LCMV (Linear Constrained Minimal Variance)
        if ismember(LCMV, method)
            cfg                   = struct;
            cfg.method            = 'lcmv';
            cfg.grid              = sourcemodel;
            cfg.headmodel         = headmodel;
            cfg.lcmv.projectnoise = 'yes';
            cfg.elec              = elec;
            cfg.lcmv.keepfilter   = 'no';
            cfg.lcmv.keepcov      = 'yes';
            cfg.lcmv.keepmom      = 'no';

            cfg.lcmv.lambda = lcmvLambdas(1);
            source.(LCMV).x = ft_sourceanalysis(cfg, timelockX); % TODO read doc
            source.(LCMV).x.avg.nai = source.(LCMV).x.avg.pow ./ source.(LCMV).x.avg.noise;

            cfg.lcmv.lambda = lcmvLambdas(2);
            source.(LCMV).y = ft_sourceanalysis(cfg, timelockY);
            source.(LCMV).y.avg.nai = source.(LCMV).y.avg.pow ./ source.(LCMV).y.avg.noise;

            cfg.lcmv.lambda = lcmvLambdas(3);
            source.(LCMV).z = ft_sourceanalysis(cfg, timelockZ);
            source.(LCMV).z.avg.nai = source.(LCMV).z.avg.pow ./ source.(LCMV).z.avg.noise;

            evaluation.(LCMV).maps{s} = [evaluation.(LCMV).maps{s} source.(LCMV).x.avg.nai source.(LCMV).y.avg.nai source.(LCMV).z.avg.nai];
        end
        %% eLORETA
        if ismember(ELORETA, method)
            cfg                    = [];
            cfg.method             = 'eloreta';
            cfg.grid               = sourcemodel;
            cfg.headmodel          = headmodel;
            cfg.eloreta.lambda     = eloretaLambdas(s);
            cfg.elec               = elec;
            cfg.eloreta.keepfilter = 'no';
            cfg.eloreta.keepmom    = 'no';

            source.(ELORETA).x = ft_sourceanalysis(cfg, timelockX);
            source.(ELORETA).x.avg.pow = source.(ELORETA).x.avg.pow'; % TODO why transpose
            source.(ELORETA).y = ft_sourceanalysis(cfg, timelockY);
            source.(ELORETA).y.avg.pow = source.(ELORETA).y.avg.pow';
            source.(ELORETA).z = ft_sourceanalysis(cfg, timelockZ);
            source.(ELORETA).z.avg.pow = source.(ELORETA).z.avg.pow';

            evaluation.(ELORETA).maps{s} = [evaluation.(ELORETA).maps{s} source.(ELORETA).x.avg.pow source.(ELORETA).y.avg.pow source.(ELORETA).z.avg.pow];
        end
        
        %% Metrics
        %% ED1
        cfg = struct;
        cfg.dipoleIdx = d;
        cfg.sourcemodel = sourcemodel;
        cfg.returnOne = true;
        valueParameter.default = 'pow';
        valueParameter.(LCMV) = 'nai';
        for m = 1:nMethod
            if isfield(valueParameter, method(m))
                param = valueParameter.(method(m));
            else
                param = valueParameter.default;
            end
            
            cfg.dipoleValues = source.(method(m)).x.avg.(param);
            evaluation.(method(m)).ED1(s,1,d) = ed1(cfg);
            cfg.dipoleValues = source.(method(m)).y.avg.(param);
            evaluation.(method(m)).ED1(s,2,d) = ed1(cfg);
            cfg.dipoleValues = source.(method(m)).z.avg.(param);
            evaluation.(method(m)).ED1(s,3,d) = ed1(cfg);
        end
        %% ED2
        % TODO ?
        
        %% Update waitbar
        bar = bar + 1;
        time = toc(iterationStart);
        estimated_time = (time * (bar_max - bar)) / 60; % [min]
        waitbar(bar / bar_max, fig, {['Computed: ' num2str(bar) ' / ' num2str(bar_max)], ['Estimated Time Remaining: ' num2str(estimated_time) ' min']});
    end
end
waitbar(1, fig, 'Done');

%% Evaluate & Save
for m = 1:nMethod
    evaluation.(method(m)).ED1mean = mean(evaluation.(method(m)).ED1, 3);
    evaluation.(method(m)).ED1std = std(evaluation.(method(m)).ED1, 0, 3);
end
save([outputPath '\evaluation'], 'evaluation');
%%
% TODO table from 'evaluation' struct
method = make_column(method);
method = repmat(method, nSNR, 1);
SNR = repelem(SNR, nMethod);
SNR = make_column(SNR);
nCombinations = nMethod * nSNR;
xMean = zeros(nCombinations, 1);
yMean = zeros(nCombinations, 1);
zMean = zeros(nCombinations, 1);
xSTD = zeros(nCombinations, 1);
ySTD = zeros(nCombinations, 1);
zSTD = zeros(nCombinations, 1);
for m = 1:nMethod
    startIdx = (m-1)*nSNR+1;
    endIdx = m*nSNR;
    xMean(startIdx:endIdx) = evaluation.(method(m)).ED1mean(:,1);
    yMean(startIdx:endIdx) = evaluation.(method(m)).ED1mean(:,2);
    zMean(startIdx:endIdx) = evaluation.(method(m)).ED1mean(:,3);
    xSTD(startIdx:endIdx) = evaluation.(method(m)).ED1std(:,1);
    ySTD(startIdx:endIdx) = evaluation.(method(m)).ED1std(:,2);
    zSTD(startIdx:endIdx) = evaluation.(method(m)).ED1std(:,3);
end
evaluationTable = table(method, SNR, xMean, xSTD, yMean, ySTD, zMean, zSTD)
save([outputPath '\evaluation_table'], 'evaluationTable');
