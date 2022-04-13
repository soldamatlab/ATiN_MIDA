function [tissueFT, tissueMT, label] = match_layers_FT3_MT12(segmentationFT, segmentationMT)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
tissueFT = zeros(size(segmentationFT.tissue));
tissueMT = zeros(size(segmentationFT.tissue));
label = {'brain' 'other' 'background'};

% brain
tissueFT(segmentationFT.(FIELDTRIP_3_LABEL{1})) = 1; % brain
tissueMT(segmentationMT.(MRTIM_12_LABEL{1})) = 1; % bgm
tissueMT(segmentationMT.(MRTIM_12_LABEL{2})) = 1; % cgm
tissueMT(segmentationMT.(MRTIM_12_LABEL{3})) = 1; % bwm
tissueMT(segmentationMT.(MRTIM_12_LABEL{4})) = 1; % cwm
tissueMT(segmentationMT.(MRTIM_12_LABEL{5})) = 1; % brainstem
% ! brainstem is part of fieldtrip: gray, white, skull, scalp
tissueMT(segmentationMT.(MRTIM_12_LABEL{6})) = 1; % csf

% other
tissueFT(segmentationFT.(FIELDTRIP_3_LABEL{2})) = 2; % skull
tissueFT(segmentationFT.(FIELDTRIP_3_LABEL{3})) = 2; % scalp
tissueMT(segmentationMT.(MRTIM_12_LABEL{7})) = 2; % spongiosa
tissueMT(segmentationMT.(MRTIM_12_LABEL{8})) = 2; % compacta
tissueMT(segmentationMT.(MRTIM_12_LABEL{9})) = 2; % muscle
tissueMT(segmentationMT.(MRTIM_12_LABEL{10})) = 2; % fat
tissueMT(segmentationMT.(MRTIM_12_LABEL{11})) = 2; % eyes
tissueMT(segmentationMT.(MRTIM_12_LABEL{12})) = 2; % skin

% background
tissueFT(segmentationFT.tissue == 0) = 3;
tissueMT(segmentationMT.tissue == 0) = 3;
end

