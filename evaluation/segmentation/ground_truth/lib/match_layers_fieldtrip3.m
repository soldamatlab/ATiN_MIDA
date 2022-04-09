function [seg, truth, label] = match_layers_fieldtrip3(mriSegmented, groundTruth)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
seg = zeros(size(groundTruth.anatomy));
truth = zeros(size(groundTruth.anatomy));
label = {'brain' 'other'};

% brain
seg(mriSegmented.(FIELDTRIP_3_LABEL{1})) = 1; % brain
truth(groundTruth.(SCI_LABEL{2})) = 1; % gray
truth(groundTruth.(SCI_LABEL{3})) = 1; % white
truth(groundTruth.(SCI_LABEL{4})) = 1; % csf

% other tissues
seg(mriSegmented.(FIELDTRIP_3_LABEL{2})) = 2; % bone
seg(mriSegmented.(FIELDTRIP_3_LABEL{3})) = 2; % scalp
truth(groundTruth.(SCI_LABEL{1})) = 2; % eyes
truth(groundTruth.(SCI_LABEL{6})) = 2; % bone
truth(groundTruth.(SCI_LABEL{5})) = 2; % cavity
truth(groundTruth.(SCI_LABEL{7})) = 2; % soft
end

