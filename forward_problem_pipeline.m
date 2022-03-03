function [] = forward_problem_pipeline(Config)
%FORWARD_PROBLEM_PIPELINE TODO Summary of this function
%   TODO Detailed explanation
%% Import
wd = fileparts(mfilename('fullpath'));
addpath([wd '\lib']);
addpath([wd '\common']);
addpath([wd '\segmentation\fieldtrip']);
addpath([wd '\segmentation\mrtim']);
addpath([wd '\model\fieldtrip']);

%% Config
% TODO check number of segmentation and model methods

outputPath = get_output_path(Config);
segmentationPath = [outputPath '\segmentation'];
modelPath = [outputPath '\model'];
Info = struct;

%% Segmentation
% TODO add try catch blocks
if isfield(Config.segmentation, 'fieldtrip')
    Info.segmentation.fieldtrip.finished = true;
    Config.segmentation.fieldtrip.path.output = [segmentationPath '\fieldtrip'];
    try
        segmentation_fieldtrip(Config.segmentation.fieldtrip);
    catch ftSegmentationError
        Info.segmentation.fieldtrip.finished = false;
        submodule_error_warning("FieldTrip segmentation", ftSegmentationError)
    end
end

if isfield(Config.segmentation, 'brainstorm')
    % TODO not implemented
    warning("Segmentation with Brainstorm is not yet implemented. Skipping.")
end

if isfield(Config.segmentation, 'mrtim')
    Info.segmentation.mrtim.finished = true;
    Config.segmentation.mrtim.path.output = [segmentationPath '\mrtim'];
    try
        segmentation_mrtim(Config.segmentation.mrtim);
    catch mrtimSegmentationError
        Info.segmentation.mrtim.finished = false;
        submodule_error_warning("MR-TIM segmentation", mrtimSegmentationError)
    end
end

%% Model conductivity
if isfield(Config.model, 'fieldtrip')
    Info.model.fieldtrip.finished = true;
    Config.model.fieldtrip.path.output = [modelPath '\fieldtrip'];
    try
        model_fieldtrip(Config.segmentation.fieldtrip);
    catch ftModelError
        Info.model.fieldtrip.finished = false;
        submodule_error_warning("FieldTrip conductivity modelling", ftModelError)
    end
end

if isfield(Config.model, 'brainstorm')
    % TODO not implemented
    warning("Conductivity modeling with Brainstorm is not yet implemented. Skipping.")
end

%% Save additional files
save([outputPath '\config'],'Config');
save([outputPath '\info'],'Info');

end

