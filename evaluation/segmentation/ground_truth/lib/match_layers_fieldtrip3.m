function [seg, truth, label] = match_layers_fieldtrip3(mriSegmented, groundTruth)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
seg = zeros(size(groundTruth.anatomy));
truth = zeros(size(groundTruth.anatomy));
label = {'brain' 'bone' 'soft'};

% brain
seg(mriSegmented.(FIELDTRIP_3_LABEL{1})) = 1;
truth(groundTruth.(SCI_LABEL{2})) = 1;
truth(groundTruth.(SCI_LABEL{3})) = 1;
truth(groundTruth.(SCI_LABEL{4})) = 1;

% bone
seg(mriSegmented.(FIELDTRIP_3_LABEL{2})) = 2;
truth(groundTruth.(SCI_LABEL{6})) = 2;

% other tissue
seg(mriSegmented.(FIELDTRIP_3_LABEL{3})) = 3;
truth(groundTruth.(SCI_LABEL{1})) = 3; % eyes
truth(groundTruth.(SCI_LABEL{5})) = 3; % cavity
truth(groundTruth.(SCI_LABEL{7})) = 3; % soft
end

