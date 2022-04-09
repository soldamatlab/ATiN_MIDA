function [seg, truth, label] = match_layers_fieldtrip5(mriSegmented, groundTruth)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
seg = zeros(size(groundTruth.tissue));
truth = zeros(size(groundTruth.tissue));
label = {'gray' 'white' 'csf' 'other'};

% gray
seg(mriSegmented.(FIELDTRIP_5_LABEL{1})) = 1;
truth(groundTruth.(SCI_LABEL{2})) = 1;

% white
seg(mriSegmented.(FIELDTRIP_5_LABEL{2})) = 2;
truth(groundTruth.(SCI_LABEL{3})) = 2;

% csf
seg(mriSegmented.(FIELDTRIP_5_LABEL{3})) = 3;
truth(groundTruth.(SCI_LABEL{4})) = 3;

% other tissues
seg(mriSegmented.(FIELDTRIP_5_LABEL{4})) = 4; % bone
seg(mriSegmented.(FIELDTRIP_5_LABEL{5})) = 4; % scalp
truth(groundTruth.(SCI_LABEL{1})) = 4; % eyes
truth(groundTruth.(SCI_LABEL{5})) = 4; % cavity
truth(groundTruth.(SCI_LABEL{6})) = 4; % bone
truth(groundTruth.(SCI_LABEL{7})) = 4; % soft
end

