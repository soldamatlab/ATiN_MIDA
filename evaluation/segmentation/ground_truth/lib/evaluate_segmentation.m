function [result] = evaluate_segmentation(segmentation, groundTruth)
%% Check Input
check_required_field(segmentation, 'tissue');
check_required_field(groundTruth, 'tissue');
check_required_field(segmentation, 'tissuelabel');
check_required_field(groundTruth, 'tissuelabel');
if ~isequal(segmentation.tissuelabel, groundTruth.tissuelabel)
    error("segmentation.tissuelabel != groundTruth.tissuelabel. [segmentation] and [groundTruth] need to be segmented into the same layers.")
end
if ~isequal(size(segmentation.tissue), size(groundTruth.tissue))
    error("size(segmentation.tissue) != size(groundTruth.tissue). [segmentation] needs to be interpolated so that the dimensions match with [groundTruth].")
end

label = groundTruth.tissuelabel;
segmentation = ensure_masks(segmentation);
groundTruth = ensure_masks(groundTruth);

%% Evaluate
result = struct;
errorMesh = struct;
absoluteError = struct;
relativeError = struct;
errorMesh.tissue = segmentation.tissue ~= groundTruth.tissue;
absoluteError.tissue = sum(errorMesh.tissue, 'all');
result.numel.tissue = numel(errorMesh.tissue);
relativeError.tissue = absoluteError.tissue / result.numel.tissue;

absoluteError.maskSum = 0;
result.numel.maskSum = 0;
for l = 1:length(label)
    errorMesh.(label{l}) = segmentation.(label{l}) ~= groundTruth.(label{l});
    absoluteError.(label{l}) = sum(errorMesh.(label{l}), 'all');
    absoluteError.maskSum = absoluteError.maskSum + absoluteError.(label{l});
    
    result.numel.(label{l}) = numel(errorMesh.(label{l}));
    result.numel.maskSum = result.numel.maskSum + result.numel.(label{l});
    relativeError.(label{l}) = absoluteError.(label{l}) / result.numel.(label{l});
end
relativeError.maskSum = absoluteError.maskSum / result.numel.maskSum;

result.errorMesh = errorMesh;
result.absoluteError = absoluteError;
result.relativeError = relativeError;
end

