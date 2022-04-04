function [seg, truth, label] = match_layers_fieldtrip5(mriSegmented, groundTruth)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
seg = zeros(size(groundTruth.anatomy));
truth = zeros(size(groundTruth.anatomy));
label = {'gray' 'white' 'csf' 'bone' 'soft'};

% gray
seg(mriSegmented.(FIELDTRIP_5_LABEL{1})) = 1;
truth(groundTruth.(SCI_LABEL{2})) = 1;

% white
seg(mriSegmented.(FIELDTRIP_5_LABEL{2})) = 2;
truth(groundTruth.(SCI_LABEL{3})) = 2;

% csf
seg(mriSegmented.(FIELDTRIP_5_LABEL{3})) = 3;
truth(groundTruth.(SCI_LABEL{4})) = 3;

% bone
seg(mriSegmented.(FIELDTRIP_5_LABEL{4})) = 4;
truth(groundTruth.(SCI_LABEL{6})) = 4;

% other tissue
seg(mriSegmented.(FIELDTRIP_5_LABEL{5})) = 5;
truth(groundTruth.(SCI_LABEL{1})) = 5; % eyes
truth(groundTruth.(SCI_LABEL{5})) = 5; % cavity
truth(groundTruth.(SCI_LABEL{7})) = 5; % soft
end

