%% Init
clear variables
close all
addpath_source;

%% Paths & Constants
eegPath = 'S:\BP_MIDA\data\EEG';

T_EVENT = 5; % [s]

%% Find EEG files
eegFiles = dir([eegPath '\bino-*_*_*.mat']);
nFiles = length(eegFiles);

%% Cut EEG files
for f = 1:nFiles
    %% Load EEG data
    fullPath = [eegFiles.folder '\' eegFiles.name];
    file = load(fullath);
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
    save([eegFiles.folder '\' eegFiles.name '_cut'], 'data', 'events');
end
