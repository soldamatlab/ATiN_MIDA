function [eventData] = create_event_data(data, timestamps, Tevent)
time = data.time{1};
trial = data.trial{1};
fs = length(time) / (time(end) - time(1));
nEvents = length(timestamps);

eventData = data;
eventData.trial = cell(1, nEvents);
eventData.time  = cell(1, nEvents);
eventData = rmfield(eventData, 'sampleinfo');
eventData.fsample = fs;

for h = 1:nEvents
    indexes = timestamps(h) : timestamps(h) + floor(fs * Tevent);
    eventData.trial{h} = trial(:,indexes);
    eventData.time{h}  = time(:,indexes);
end
end

