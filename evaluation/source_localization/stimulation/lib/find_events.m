function [indexes] = find_events(events, fieldname, value)
nEvents = length(events);
nValues = 0;
for e = 1:nEvents
    if strcmp(events(e).(fieldname), value)
        nValues = nValues + 1;
        indexes(nValues) = e;
    end
end
end
