function [segmentation] = ensure_tissue_and_masks(Config, segmentation)
%% Config
Config = check_tissue_function_config(Config);

%%
label = get_label(Config.method, Config.nLayers);

if masks_present(segmentation, label)
    if isfield(segmentation, 'tissue')
        if ~match_tissue_and_masks(segmentation, label)
            error("Both 'tissue' and masks are present but don't match in dimensions.")
        end
    else
        segmentation = add_tissue(Config, segmentation);
    end
    return
end

if isfield(segmentation, 'tissue')
    segmentation.tissuelabel = label;
    segmentation = add_tissue_masks(Config, segmentation);
    return
end

if isfield(segmentation, 'seg')
    segmentation = assume_tissue(Config, segmentation, label, 'seg');
    return
end

if isfield(segmentation, 'anatomy')
    segmentation = assume_tissue(Config, segmentation, label, 'anatomy');
    return
end

error("Cannot add 'tissue' field and tissue masks. MRI doesn't contain either.")
end

