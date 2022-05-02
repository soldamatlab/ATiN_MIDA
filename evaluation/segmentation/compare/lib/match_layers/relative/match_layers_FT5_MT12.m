function [tissueFT, tissueMT, label] = match_layers_FT5_MT12(segmentationFT, segmentationMT)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
tissueFT = zeros(size(segmentationFT.tissue));
tissueMT = zeros(size(segmentationFT.tissue));
label = {'gray' 'white' 'csf' 'other' 'background'};

% gray
%tissueFT(segmentationFT.(FIELDTRIP_5_LABEL{1})) = 1; % gray
tissueMT(segmentationMT.(MRTIM_12_LABEL{1})) = 1; % bgm
tissueMT(segmentationMT.(MRTIM_12_LABEL{2})) = 1; % cgm

% white
tissueFT(segmentationFT.(FIELDTRIP_5_LABEL{2})) = 2; % white
tissueMT(segmentationMT.(MRTIM_12_LABEL{3})) = 2; % bwm
tissueMT(segmentationMT.(MRTIM_12_LABEL{4})) = 2; % cwm
tissueMT(segmentationMT.(MRTIM_12_LABEL{5})) = 2; % brainstem
% ! brainstem is part of fieldtrip: gray, white, skull, scalp

% csf
tissueFT(segmentationFT.(FIELDTRIP_5_LABEL{3})) = 3; % csf
tissueMT(segmentationMT.(MRTIM_12_LABEL{6})) = 3; % csf

% other
tissueFT(segmentationFT.(FIELDTRIP_5_LABEL{4})) = 4; % skull
tissueFT(segmentationFT.(FIELDTRIP_5_LABEL{5})) = 4; % scalp
tissueMT(segmentationMT.(MRTIM_12_LABEL{7})) = 4; % spongiosa
tissueMT(segmentationMT.(MRTIM_12_LABEL{8})) = 4; % compacta
tissueMT(segmentationMT.(MRTIM_12_LABEL{9})) = 4; % muscle
tissueMT(segmentationMT.(MRTIM_12_LABEL{10})) = 4; % fat
tissueMT(segmentationMT.(MRTIM_12_LABEL{11})) = 4; % eyes
tissueMT(segmentationMT.(MRTIM_12_LABEL{12})) = 4; % skin

% background
tissueFT(segmentationFT.tissue == 0) = 5;
tissueMT(segmentationMT.tissue == 0) = 5;
end

