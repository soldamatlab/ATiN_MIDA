function [segmentation] = ensure_masks(segmentation)
check_required_field(segmentation, 'tissue');
check_required_field(segmentation, 'tissuelabel');
label = segmentation.tissuelabel;

if masks_present(segmentation, label)
    if ~match_tissue_and_masks(segmentation, label)
        error("Masks are present but don't match the dimension of 'tissue' field.")
    end
else
    cfg = struct;
    segmentation = add_tissue_masks(cfg, segmentation);
end
end

