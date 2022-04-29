% TODO better done through:
% classdef Const
%    properties( Constant = true )
%        var = 0;
%    end
% end

%% DO NOT REORDER LABELS
% Reordering labels requires fixing some usages too.

% ___ FieldTrip 3 layers _________________________________________________
FIELDTRIP_3_COND  = [ 0.33    0.01    0.43  ];
FIELDTRIP_3_LABEL = {'brain' 'skull' 'scalp'};

% ___ FieldTrip 5 layers _________________________________________________
% FIELDTRIP_5 = [0.43 0.0024 1.79 0.14 0.33]; % tutorial, same as tissuelabel in vol_simbio
FIELDTRIP_5_COND  = [  0.33   0.14    1.79  0.01    0.43  ];
FIELDTRIP_5_LABEL = { 'gray' 'white' 'csf' 'skull' 'scalp'};

% ___ MR-TIM 6 layers ____________________________________________________
MRTIM_6_COND  = [0 0 0 0 0 0]; % TODO
MRTIM_6_LABEL = {'' '' '' '' '' ''};

% ___ MR-TIM 12 layers ___________________________________________________
%0:  background
%1:  brain gray matter (bGM)
%2:  cerebellar GM (cGM)
%3:  brain white matter (bWM)
%4:  cerebellar WM (cWM)
%5:  brainstem
%6:  cerebrospinal fluid (CSF)
%7:  skull - spongiosa
%8:  skull - compacta
%9:  muscle
%10: fat
%11: eyes
%12: skin
%                  1     2     3     4     5           6     7           8          9        10    11     12
MRTIM_12_COND  = [ 0.3333 0.2564 0.1429 0.1099 0.1538      1.5385 0.0400      0.0063     0.1000   0.0400 0.5000 0.4348];
MRTIM_12_LABEL = {'bgm'  'cgm'  'bwm'  'cwm'  'brainstem' 'csf'  'spongiosa' 'compacta' 'muscle' 'fat'  'eyes' 'skin' };
% source:
% Liu Q, Farahibozorg S, Porcaro C, Wenderoth N, Mantini D. Detecting large-scale networks in the human brain using high-density electroencephalography. 2017
% (Liu 2017)
% Supporting Information Table S2

% ___ SCI Segmentation ___________________________________________________
% Manually plotted and determined:
%             1     2       3       4     5        6      7      8
SCI_LABEL = {'eyes' 'gray' 'white' 'csf' 'sinus' 'bone' 'soft' 'background'};
