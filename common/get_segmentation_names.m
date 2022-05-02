function [segmentations, nSegmentations] = get_segmentation_names(methods, layers, suffixes)
methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);

nSegmentations = length(methods);
segmentations = cell(1, nSegmentations);
for m = 1:nSegmentations
    suffix = '';
    if ~isempty(suffixes{m})
        suffix = ['_' suffixes{m}];
    end
    segmentations{m} = [methods{m} num2str(layers(m)) suffix];
end
end
