function [tissue3, tissue5, label] = match_layers_FT3_FT5(segmentation3, segmentation5)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
tissue3 = zeros(size(segmentation3.tissue));
tissue5 = zeros(size(segmentation3.tissue));
label = FIELDTRIP_3_LABEL;

% brain
tissue3(segmentation3.(FIELDTRIP_3_LABEL{1})) = 1; % brain
tissue5(segmentation5.(FIELDTRIP_5_LABEL{1})) = 1; % gray
tissue5(segmentation5.(FIELDTRIP_5_LABEL{2})) = 1; % white
tissue5(segmentation5.(FIELDTRIP_5_LABEL{3})) = 1; % csf

% skull
tissue3(segmentation3.(FIELDTRIP_3_LABEL{2})) = 2; % skull
tissue5(segmentation5.(FIELDTRIP_5_LABEL{4})) = 2; % skull

% scalp
tissue3(segmentation3.(FIELDTRIP_3_LABEL{3})) = 3; % scalp
tissue5(segmentation5.(FIELDTRIP_5_LABEL{5})) = 3; % scalp

end

