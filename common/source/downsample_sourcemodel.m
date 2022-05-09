function [sourcemodel, keep] = downsample_sourcemodel(sourcemodel, downsample)
N_AXES = 3;

%% Donwsample sourcemodel
keep = true(size(sourcemodel.pos(:,1)));
for a = 1:N_AXES
    idx = pos2idx(sourcemodel.pos(:,a)) - 1; % '-1' to index from 0
    keep = keep & (~rem(idx, downsample) | (idx == max(idx)));
end

sourcemodel.pos = sourcemodel.pos(keep,:);
sourcemodel.inside = sourcemodel.inside(keep);
sourcemodel.leadfield = sourcemodel.leadfield(keep);

for a = 1:N_AXES
    sourcemodel.dim(a) = length(unique(sourcemodel.pos(:,a)));
end
end
