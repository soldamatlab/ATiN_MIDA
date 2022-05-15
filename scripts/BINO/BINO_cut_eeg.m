%% Init
clear variables
close all
addpath_source;

%% Paths & Constants
eegPath = 'S:\BP_MIDA\data\EEG'; % PC-MATOUS
%eegPath = '\\Pc-matous\bp_mida\data\BINO\EEG'; % PC-MATOUS remote

%% Find EEG files
eegFiles = dir([eegPath '\bino-*_*_*.mat']);
nFiles = length(eegFiles);

%% Cut EEG files
for f = 1:nFiles
    %% Load EEG data
    fullPath = [eegFiles(f).folder '\' eegFiles(f).name];
    file = load(fullPath);
    if ~(isfield(file, 'dataRaw') && isfield(file, 'evt'))
        warning("Failed to load 'dataRaw' and 'evt' from '%s'.", fullPath)
        continue
    end
    data = file.dataRaw;
    events = file.evt;
    clear file
    
    %% Find last event
    lastIndex = find_events(events, 'value', 'boundary');
    lastIndex = lastIndex(1); % to be sure there's one
    lastTimeIndex = event_indexes2time_indexes(events, lastIndex, data.time{1});
    
    %% Cut data
    events = events(1:lastIndex);
    trial = data.trial{1};
    data.trial{1} = trial(:, 1:lastTimeIndex);
    time = data.time{1};
    data.time{1} = time(1:lastTimeIndex);
    data.sampleinfo = [1, lastTimeIndex];
    
    %% Save data
    name = split(eegFiles(f).name, '.');
    save([eegFiles(f).folder '\' name{1} '_cut.mat'], 'data', 'events');
end
