function [masksPresent] = masks_present(segmentation, label)
masksPresent = true;
for l = 1:length(label)
    if ~isfield(segmentation, label{l})
        masksPresent = false;
        break
    end
end
end

