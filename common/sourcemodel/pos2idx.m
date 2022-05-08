function [idx] = pos2idx(pos)
pos = pos - min(pos);
resolution = min(nonzeros(pos));
idx = pos / resolution;
idx = idx + 1;
end
