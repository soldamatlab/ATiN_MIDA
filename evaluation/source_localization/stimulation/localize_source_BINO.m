function [sourceHouses, sourceFaces] = localize_source_BINO(Config, data, events)
% LOCALIZE_SOURCE_BINO
% localize_source_BINO will re-reference eeg data to average if 'VREF' or 'EREF'
% (case ignored) is found in 'eegData.label'. Otherwise, egg data are
% assumed to be referenced to average.
%
% Required:
%   Config                = struct
%   Config.sourcemodel    = struct, has to include field 'leadfield'
%   Config.headmodel
%
%   data                  = struct
%   data.trial
%   data.time
%
% Optional:
%   Config.rereference    = 'avg' (dafault), to re-reference EEG data to average
%                         = 'no' to not re-reference data
%   Config.channel        = index or array of indexes of channels to use
%                         = 'all' to use all present channels
%                         = [1:256] by default
%

%% Constants
ELORETA = 'eloreta';
ELORETA_LAMBDA = 0.257843673057386; % ! TODO
T_EVENT = 5; % [s]

%% Check Config
check_required_field(Config, 'output');
[output, ~] = create_output_folder(Config.output, false, false);

if isfield(Config, 'channel')
    Config.channel = convertStringsToChars(Config.channel);
else
    Config.channel = 1:256;
end

if ~isfield(Config, 'rereference')
    Config.rereference = 'avg';
end

%% Check data
check_required_field(data, 'trial');
check_required_field(data, 'time');

%% Check models
check_required_field(Config, 'sourcemodel');
check_required_field(Config.sourcemodel, 'leadfield');
check_required_field(Config, 'headmodel');
if ~(isfield(Config, 'elec') || isfield(headmodel, 'elec'))
    error("Include elec structure in 'Config.elec' or 'headmodel.elec'.")
end

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

%% Find 'HRep' and 'FRep' events
iHevent = find_events(events, 'type', 'HRep');
iFevent = find_events(events, 'type', 'FRep');
iHtime = event_indexes2time_indexes(events, iHevent, data.time{1});
iFtime = event_indexes2time_indexes(events, iFevent, data.time{1});
dataHouses = create_event_data(data, iHtime(1), T_EVENT); % TODO ? not just first
dataFaces = create_event_data(data, iFtime(1), T_EVENT); % TODO

%% Preprocess - re-reference
cfg = [];
if strcmp(Config.rereference, 'no')
elseif strcmp(Config.rereference, 'avg')
    cfg.refmethod = 'avg';
else
    warning("[Config.rereference] value ('%s') is not a valid re-referencing method. Data won't be re-referenced.", Config.rereference)
end
cfg.channel = 'all'; % default
cfg.reref = 'yes';
cfg.refmethod = 'avg';
cfg.refchannel = 'all';
%cfg.demean = 'yes'; % TODO ?
dataHouses = ft_preprocessing(cfg, dataHouses);
dataFaces = ft_preprocessing(cfg, dataFaces);

%% Covariance Matrix
cfg                  = [];
cfg.covariance       = 'yes';
cfg.covariancewindow = 'all';
cfg.keeptrials       = 'no';
cfg.vartrllength     = 2;
timelockHouses = ft_timelockanalysis(cfg, dataHouses);
timelockFaces = ft_timelockanalysis(cfg, dataFaces);

%% Solve eLORETA
cfg                    = [];
cfg.method             = 'eloreta';
cfg.grid               = Config.sourcemodel;
cfg.headmodel          = Config.headmodel;
cfg.eloreta.lambda     = ELORETA_LAMBDA;
if isfield(Config, 'elec')
    cfg.elec = Config.elec;
else
    cfg.elec = headmodel.elec;
end
cfg.eloreta.keepfilter = 'no';
cfg.eloreta.keepmom    = 'no';

sourceHouses = ft_sourceanalysis(cfg, timelockHouses);
sourceHouses.avg.pow = sourceHouses.avg.pow'; % TODO why transpose
evaluation.(ELORETA).house.map = sourceHouses.avg.pow;

sourceFaces = ft_sourceanalysis(cfg, timelockFaces);
sourceFaces.avg.pow = sourceFaces.avg.pow'; % TODO why transpose
evaluation.(ELORETA).house.map = sourceFaces.avg.pow;

%% Save
% TODO save / evaluate more 
save([output '\evaluation'], 'evaluation');
end
