function [index] = get_time_index(time, when)
for t = 1:length(time)
    if time(t) == when
        index = t;
        break
    elseif time(t) > when
        if t > 0
            index = t - 1;
        else
            index = t;
        end
        break
    end
end
end
