function [configSegmentation] = segmentation2config(segmentationMethod, folderPath, nLayers)
%% Constants
fieldtripFileName = 'mri_segmented.mat'; % TODO move filenames to const file
mrtimFileName = 'mri_segmented.mat';

fieldtripDefaultNLayers = 5; % TODO move to const file
mrtimDefaultNLayers = 12;

%% Function Body
configSegmentation = struct;
configSegmentation.method = segmentationMethod;

if segmentationMethod == "fieldtrip"
    configSegmentation.path = [folderPath '\' fieldtripFileName];    
elseif segmentationMethod == "mrtim"
    configSegmentation.path = [folderPath '\' mrtimFileName];
end

if exist('nLayers','var')
    configSegmentation.nLayers = nLayers;
else
    if segmentationMethod == "fieldtrip"
        default_nlayers_warning(fieldtripDefaultNLayers, segmentationMethod)
        configSegmentation.nLayers = fieldtripDefaultNLayers;  
    elseif segmentationMethod == "mrtim"
        default_nlayers_warning(mrtimDefaultNLayers, segmentationMethod)
        configSegmentation.nLayers = mrtimDefaultNLayers;
    end
end
end

