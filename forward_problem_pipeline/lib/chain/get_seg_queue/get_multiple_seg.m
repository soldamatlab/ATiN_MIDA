function [SegQueue] = get_multiple_seg(Segmentation, methods)
SegQueue = struct;
for m = 1:numel(methods)
    SingleQueue = get_single_seg(Segmentation, methods{m});
    if ~isempty(fieldnames(SingleQueue))
        SegQueue.(methods{m}) = SingleQueue.(methods{m});
    end
end
end

