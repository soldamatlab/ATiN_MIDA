function [idx] = positions2indexes(pos)
idx = NaN(size(pos));
idx(:,1) = pos2idx(pos(:,1));
idx(:,2) = pos2idx(pos(:,2));
idx(:,3) = pos2idx(pos(:,3));
end
