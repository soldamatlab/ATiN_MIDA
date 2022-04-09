function [segmentation] = assume_tissue(Config, segmentation, label, fieldname)
warning("Assuming '%s' is 'tissue' segmentation. Renaming '%s' to 'tissue'.", fieldname, fieldname)
segmentation.tissue = segmentation.(fieldname);
segmentation = rmfield(segmentation, fieldname);
segmentation.tissuelabel = label;
segmentation = add_tissue_masks(Config, segmentation);
end

