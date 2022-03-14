function [SegQueue] = get_single_seg(Segmentation, method)
SegQueue = struct;

if ~isfield(Segmentation, method)
    warning("Segmentation method '%s' specified in config but not found in Segmentation submodule output. Skipping.", method)
    return
end

SegQueue.(method) = Segmentation.(method);
end

