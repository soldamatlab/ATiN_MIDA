function [match] = match_tissue_and_masks(segmentation, label)
match = true;
for l = 1:length(label)
    if ~isequal(size(segmentation.(label{l})), size(segmentation.tissue))
        match = false;
        break
    end
end
end

