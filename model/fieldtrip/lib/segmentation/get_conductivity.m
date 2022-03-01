function [conductivity, tissueLabel] = get_conductivity(method, nLayers)
%FieldTrip 5 layers
% FIELDTRIP_5 = [0.43 0.0024 1.79 0.14 0.33]; % tutorial, same as tissuelabel in vol_simbio
FIELDTRIP_5 =       [ 1.79  0.33   0.43    0.01    0.14  ];
FIELDTRIP_5_LABEL = {'csf' 'gray' 'scalp' 'skull' 'white'};

%MR-TIM 6 layers
MRTIM_6 = [0 0 0 0 0 0]; % TODO
MRTIM_6_LABEL = {'' '' '' '' '' ''};

%MR-TIM 12 layers
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
MRTIM_12 =       [ 0.47  0.47  0.22  0.22  0.42        1.71  0.048       0.006      0.77     0.11  0.92   0.11];
MRTIM_12_LABEL = {'bgm' 'cgm' 'bwm' 'cwm' 'brainstem' 'csf' 'spongiosa' 'compacta' 'muscle' 'fat' 'eyes' 'skin'};
% Labels need to stay consistent with labeling in 'mrtim_to_datatype_segmentation'
%
% sources:
% TODO ? better sources
%
% 1=2 3=4 6 7 8
% https://pubmed.ncbi.nlm.nih.gov/31054104/#:~:text=Assigning%20conductivity%20as%3A%200.41%20S,m%20for%20WM%20and%2050.4
%
% 5 9 11 10=12
% Table 1. https://journals.plos.org/plosone/article/figures?id=10.1371/journal.pone.0183168

if method == "fieldtrip"
    if nLayers == 5
        conductivity = FIELDTRIP_5;
        tissueLabel = FIELDTRIP_5_LABEL;
        return
    end
    error("Unsupported [nLayers]. Only [nLayers] = 5 is supported for segmentation [method] = 'fieldtrip'.")
end

if method == "mrtim"
    if nLayers == 6
        error("segmentation [method] = 'mrtim' and [nLayers] = 6 not yet implemented.")
        conductivity = MRTIM_6;
        tissueLabel = MRTIM_6_LABEL;
        return
    end
    if nLayers == 12
        conductivity = MRTIM_12;
        tissueLabel = MRTIM_12_LABEL;
        return
    end
    error("Unsupported [nLayers]. [nLayers] = 6 or 12 is supported for segmentation [method] = 'mrtim'.")
end

error("Unsupported segmentation [method]. 'get_conductivity' returns conductivity for 'fieldtrip' and 'mrtim' segmentation methods.")
end

