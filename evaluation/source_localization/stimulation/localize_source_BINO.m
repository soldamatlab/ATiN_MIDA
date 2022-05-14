function [sourceHouses, sourceFaces] = localize_source_BINO(Config)
% LOCALIZE_SOURCE_BINO
% localize_source_BINO will re-reference eeg data to average if 'VREF' or 'EREF'
% (case ignored) is found in 'eegData.label'. Otherwise, egg data are
% assumed to be referenced to average.
%
% Required:
%   Config                = struct
%   Config.data
%   Config.events
%   Config.sourcemodel    = struct, has to include field 'leadfield'
%   Config.headmodel
%   Config.output
%
%   data                  = struct
%   data.trial
%   data.time
%
% Optional:
%   Config.rereference    = 'avg' (dafault), to re-reference EEG data to average
%                         = 'no' to not re-reference data
%
%   Config.channel        = index or array of indexes of channels to use
%                         = 'all' to use all present channels
%                         = [1:256] by default
%
%   Config.plot           = true (default)
%   Config.mri            = for plotting
%   Config.visualize      = true (default)
%
%   Config.allowExistingFolder = false (default)
%

%% Constants % Defaults
ELORETA = 'eloreta';
ELORETA_LAMBDA = 0.05; % regulation parameter

T_EVENT = 5; % [s]
FACES_FREQUENCY = 8.57; % [Hz]
HOUSES_FREQUENCY = 6.67; % [Hz]

FREQUENCY_HALF_MARGIN = 0.8; % [Hz]

PLOT = true;
VISUALIZE = true;
ALLOW_EXISTING_FOLDER = false;

MRI_VAR_NAME = 'mriPrepro';

%% Check Config
check_required_field(Config, 'output');
if ~isfield(Config, 'allowExistingFolder')
    Config.allowExistingFolder = ALLOW_EXISTING_FOLDER;
end
[output, imgPath] = create_output_folder(Config.output, Config.allowExistingFolder, true);

if isfield(Config, 'channel')
    Config.channel = convertStringsToChars(Config.channel);
else
    Config.channel = 1:256;
end

if ~isfield(Config, 'rereference')
    Config.rereference = 'avg';
end

if ~isfield(Config, 'plot')
    Config.plot = PLOT;
end
if ~isfield(Config, 'visualize')
    Config.visualize = VISUALIZE;
end

%% Load data from Config
check_required_field(Config, 'data');
check_required_field(Config, 'events');
check_required_field(Config.data, 'trial');
check_required_field(Config.data, 'time');
data = Config.data;
events = Config.events;

%% Load models from Config
check_required_field(Config, 'sourcemodel');
sourcemodel = Config.sourcemodel;
check_required_field(sourcemodel, 'leadfield');

check_required_field(Config, 'headmodel');
headmodel = Config.headmodel;

if isfield(Config, 'elec')
    elec = Config.elec;
elseif isfield(headmodel, 'elec')
    elec = headmodel.elec;
else
    error("Include elec structure in 'Config.elec' or 'headmodel.elec'.")
end

plotAnatomy = isfield(Config, 'mri');
if plotAnatomy % test mri path
    if isfield(Config, 'mriVarName')
        mriVarName = Config.mriVarName;
    else
        mriVarName = MRI_VAR_NAME;
    end
    mri = load_mri_anytype(Config.mri, mriVarName);
end

%% Save Config
Config.data = rm_field_data(Config.data, 'trial', 'trial');
Config.data = rm_field_data(Config.data, 'time', 'time');
Config = rm_field_data(Config, 'events', 'events');
Config = rm_field_data(Config, 'sourcemodel', 'sourcemodel');
Config = rm_field_data(Config, 'headmodel', 'headmodel');
if isfield(Config, 'elec')
    Config = rm_field_data(Config, 'elec', 'elec');
end
Config.mri = convertCharsToStrings(Config.mri);
if plotAnatomy && ~isstring(Config.mri)
    Config = rm_field_data(Config, 'mri', 'mri');
end
save([output '\config'], 'Config');

%% Pick channels
if ischar(Config.channel)
    if strcmp(Config.channel, 'all')
        % TODO check for lowest number of channels across struct
    else
        warning("[Config.channel] value ('%s') not recognized. Using all channels.", Config.channel)
    end
else
    cfg = struct;
    cfg.channel = Config.channel;
    cfg.datatype = 'data';
    data = pick_channel(cfg, data);
end

%% Preprocess - re-reference, bandpass
cfg = [];
cfg.channel = 'all'; % default
cfg.demean = 'no'; % default

if strcmp(Config.rereference, 'no')
elseif strcmp(Config.rereference, 'avg')
    cfg.reref = 'yes';
    cfg.refmethod = 'avg';
    cfg.refchannel = 'all';
else
    warning("[Config.rereference] value ('%s') is not a valid re-referencing method. Data won't be re-referenced.", Config.rereference)
end

cfg.bpfilter = 'yes';
cfg.bpfreq = [HOUSES_FREQUENCY - FREQUENCY_HALF_MARGIN, HOUSES_FREQUENCY + FREQUENCY_HALF_MARGIN];
dataHouses = ft_preprocessing(cfg, data);
cfg.bpfreq = [FACES_FREQUENCY - FREQUENCY_HALF_MARGIN, FACES_FREQUENCY + FREQUENCY_HALF_MARGIN];
dataFaces = ft_preprocessing(cfg, data);

%% Find 'HRep' and 'FRep' events
iHevent = find_events(events, 'type', 'HRep');
iFevent = find_events(events, 'type', 'FRep');
iHtime = event_indexes2time_indexes(events, iHevent, dataHouses.time{1});
iFtime = event_indexes2time_indexes(events, iFevent, dataFaces.time{1});
dataHouses = create_event_data(dataHouses, iHtime(1:5), T_EVENT); % TODO ? not just first
dataFaces = create_event_data(dataFaces, iFtime(1:5), T_EVENT); % TODO

%% Covariance Matrix
cfg                  = [];
cfg.covariance       = 'yes';
cfg.covariancewindow = 'all';
cfg.keeptrials       = 'yes';
cfg.vartrllength     = 2; % TODO study
timelockHouses = ft_timelockanalysis(cfg, dataHouses);
timelockFaces = ft_timelockanalysis(cfg, dataFaces);

%% Solve eLORETA
cfg                    = [];
cfg.method             = 'eloreta';
cfg.grid               = sourcemodel;
cfg.headmodel          = headmodel;
cfg.eloreta.lambda     = ELORETA_LAMBDA;
cfg.elec               = elec;
cfg.keeptrials         = 'no';
cfg.eloreta.keepfilter = 'no';
cfg.eloreta.keepmom    = 'no';

sourceHouses = ft_sourceanalysis(cfg, timelockHouses);
evaluation.(ELORETA).houses.map = sourceHouses.avg.pow;

sourceFaces = ft_sourceanalysis(cfg, timelockFaces);
evaluation.(ELORETA).faces.map = sourceFaces.avg.pow;

%% Save
save([output '\evaluation'], 'evaluation');

%% Plot
if ~Config.plot
    return
end
source = {sourceHouses, sourceFaces};
sourceNames = {'houses', 'faces'};
if plotAnatomy
    mri = load_mri_anytype(mri, mriVarName);
end
for s = 1:length(source)
    source{s}.pow = source{s}.avg.pow;
    source{s}.pow(isnan(source{s}.pow)) = 0;
    source{s} = rmfield(source{s}, 'avg');
    
    name = sprintf('source_%s', sourceNames{s});
    cfg = struct;
    cfg.parameter = 'pow';
    cfg.crosshair = 'no'; % default
    if plotAnatomy
        cfg.mri = mri;
    end
    cfg.name = name;
    cfg.save = [imgPath '\' cfg.name];
    cfg.visualize = Config.visualize;
    plot_source(cfg, source{s});
    cfg.name = [cfg.name '_center'];
    cfg.save = [imgPath '\' cfg.name];
    cfg.location = 'center';
    plot_source(cfg, source{s});
    %%
    if ~plotAnatomy
        continue
    end
    %%
    source{s} = rmfield(source{s}, 'inside');
    cfg = rmfield(cfg, 'location');
    cfg.name = [name '_interp'];
    cfg.save = [imgPath '\' cfg.name];
    plot_source(cfg, source{s});
    cfg.name = [cfg.name '_center'];
    cfg.save = [imgPath '\' cfg.name];
    cfg.location = 'center';
    plot_source(cfg, source{s});
end
