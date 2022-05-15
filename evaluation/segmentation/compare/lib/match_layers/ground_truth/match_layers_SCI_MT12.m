function [seg, truth, label] = match_layers_SCI_MT12(mriSegmented, groundTruth)
%% Load Constants
const_conductivity;

%% Create Matching Segmentations
seg = zeros(size(groundTruth.tissue));
truth = zeros(size(groundTruth.tissue));
label = {'gray' 'white' 'csf' 'bone' 'soft' 'eyes' 'sinus' 'background'};

% Layers are joined the same way as MR-TIM authors did in Taberna2021.

% gray
seg(mriSegmented.(MRTIM_12_LABEL{1})) = 1; % bgm
seg(mriSegmented.(MRTIM_12_LABEL{2})) = 1; % cgm
truth(groundTruth.(SCI_LABEL{2})) = 1; % gray

% white
seg(mriSegmented.(MRTIM_12_LABEL{3})) = 2; % bwm
seg(mriSegmented.(MRTIM_12_LABEL{4})) = 2; % cwm
seg(mriSegmented.(MRTIM_12_LABEL{5})) = 2; % brainstem
% ! brainstem is part of SCI: gray, white, soft
truth(groundTruth.(SCI_LABEL{3})) = 2; % white

% csf
seg(mriSegmented.(MRTIM_12_LABEL{6})) = 3;
truth(groundTruth.(SCI_LABEL{4})) = 3;

% bone
seg(mriSegmented.(MRTIM_12_LABEL{7})) = 4; % spongiosa
seg(mriSegmented.(MRTIM_12_LABEL{8})) = 4; % compacta
truth(groundTruth.(SCI_LABEL{6})) = 4; % bone

% soft
seg(mriSegmented.(MRTIM_12_LABEL{9})) = 5;  % muscle
seg(mriSegmented.(MRTIM_12_LABEL{10})) = 5; % fat
seg(mriSegmented.(MRTIM_12_LABEL{12})) = 5; % skin
truth(groundTruth.(SCI_LABEL{7})) = 5; % soft

% eyes
seg(mriSegmented.(MRTIM_12_LABEL{11})) = 6;
truth(groundTruth.(SCI_LABEL{1})) = 6;

% sinus
seg(groundTruth.(SCI_LABEL{5})) = 7; % ! uncomment to stop indexes from penalizing for sinus
truth(groundTruth.(SCI_LABEL{5})) = 7;

% background
seg(mriSegmented.tissue == 0) = 8;
truth(groundTruth.(SCI_LABEL{8})) = 8;
end

