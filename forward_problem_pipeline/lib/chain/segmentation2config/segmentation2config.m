function [configSegmentation] = segmentation2config(segmentationMethod, folderPath, nLayers)
%% Constants
FT_FILE_NAME = 'mri_segmented.mat'; % TODO move filenames to const file
MRTIM_FILE_NAME = 'mri_segmented.mat';

FT_DEFAULT_NLAYERS = 5; % TODO move to const file
MRTIM_DEFAULT_NLAYERS = 12;

%% Function Body
configSegmentation = struct;
configSegmentation.method = segmentationMethod;

if segmentationMethod == "fieldtrip"
    configSegmentation.path = [folderPath '\' FT_FILE_NAME];    
elseif segmentationMethod == "mrtim"
    configSegmentation.path = [folderPath '\' MRTIM_FILE_NAME];
end

if exist('nLayers','var')
    configSegmentation.nLayers = nLayers;
else
    if segmentationMethod == "fieldtrip"
        default_nlayers_warning(FT_DEFAULT_NLAYERS, segmentationMethod)
        configSegmentation.nLayers = FT_DEFAULT_NLAYERS;  
    elseif segmentationMethod == "mrtim"
        default_nlayers_warning(MRTIM_DEFAULT_NLAYERS, segmentationMethod)
        configSegmentation.nLayers = MRTIM_DEFAULT_NLAYERS;
    end
end
end

