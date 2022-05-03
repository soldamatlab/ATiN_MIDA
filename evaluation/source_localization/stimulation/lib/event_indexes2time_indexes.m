function [timeIndexes] = event_indexes2time_indexes(events, eventIndexes, time)
timeIndexes = NaN(1, length(eventIndexes));
for i = 1:length(eventIndexes)
    % time is in [s], events(x).sample is in [ms]
    when = events(eventIndexes(i)).sample / 1000;
    timeIndexes(i) = get_time_index(time, when);
end
end
