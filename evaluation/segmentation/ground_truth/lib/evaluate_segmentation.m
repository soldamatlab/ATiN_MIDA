function [Result, MaskResult] = evaluate_segmentation(segmentation, groundTruth)
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

%% Tissue masks & Sums
Result = struct;
MaskResult = struct;

nTissues = length(label);
for l = 1:nTissues
    MaskResult.segmentation.(label{l}) = segmentation.(label{l});
    Result.segmentation.(label{l}) = sum(segmentation.(label{l}), 'all');
    MaskResult.groundTruth.(label{l}) = groundTruth.(label{l});
    Result.groundTruth.(label{l}) = sum(groundTruth.(label{l}), 'all');
end

%% Extra & Absent
for l = 1:nTissues   
    % Extra (Segmentation - Ground Truth)
    MaskResult.extra.(label{l}) = segmentation.(label{l}) & ~groundTruth.(label{l});
    Result.extra.(label{l}) = sum(MaskResult.extra.(label{l}), 'all');
    
    % Absent (Ground Truth - Segmentation)
    MaskResult.absent.(label{l}) = ~segmentation.(label{l}) & groundTruth.(label{l});
    Result.absent.(label{l}) = sum(MaskResult.absent.(label{l}), 'all');
end

%% Union & Intersection
union = zeros(nTissues, nTissues);
unionMask = cell(nTissues, nTissues);
intersection = zeros(nTissues, nTissues);
intersectionMask = cell(nTissues, nTissues);
for seg = 1:nTissues
    for gt = 1:nTissues
        % Union
        unionMask{seg, gt} = segmentation.(label{seg}) | groundTruth.(label{gt});
        union(seg, gt) = sum(unionMask{seg, gt}, 'all');
        
        % Intersection
        intersectionMask{seg, gt} = segmentation.(label{seg}) & groundTruth.(label{gt});
        intersection(seg, gt) = sum(intersectionMask{seg, gt}, 'all');
    end
end
Result.union = union;
MaskResult.union = unionMask;
Result.intersection = intersection;
MaskResult.intersection = intersectionMask;

%% Spatial Overlap index
SO = zeros(nTissues, nTissues);
for seg = 1:length(label)
    for gt = 1:length(label)
        SO(seg, gt) = intersection(seg, gt) / Result.groundTruth.(label{gt});
    end
end
Result.spatialOverlap = SO;

%% Dice index
dice = zeros(nTissues, nTissues);
for seg = 1:length(label)
    for gt = 1:length(label)
        denominator = Result.segmentation.(label{seg}) + Result.groundTruth.(label{gt});
        dice(seg, gt) = 2 * intersection(seg, gt) / denominator;
    end
end
Result.dice = dice;

%% Jaccard index
jaccard = zeros(nTissues, nTissues);
for seg = 1:length(label)
    for gt = 1:length(label)
        jaccard(seg, gt) = intersection(seg, gt) / union(seg, gt);
    end
end
Result.jaccard = jaccard;

