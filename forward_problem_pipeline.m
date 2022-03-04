function [] = forward_problem_pipeline(Config)
%FORWARD_PROBLEM_PIPELINE TODO Summary of this function
%   TODO Detailed explanation
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\lib']));
addpath([wd '\common']);
addpath([wd '\segmentation\fieldtrip']);
addpath([wd '\segmentation\mrtim']);
addpath([wd '\model\fieldtrip']);

%% Config
% TODO check number of segmentation and model methods
outputPath = get_output_path(Config);
segmentationPath = [outputPath '\segmentation'];
modelPath = [outputPath '\model'];

Config = set_visualize(Config);

Info = struct;

%% Segmentation
if isfield(Config.segmentation, 'fieldtrip')
    Info.segmentation.fieldtrip.finished = true;
    Config.segmentation.fieldtrip.path.output = [segmentationPath '\fieldtrip'];
    Info.segmentation.fieldtrip.finished = ...
    run_submodule(segmentation_fieldtrip, Config.segmentation.fieldtrip, "FieldTrip segmentation");
end

if isfield(Config.segmentation, 'brainstorm')
    % TODO implement
    warning("Segmentation with Brainstorm is not yet implemented. Skipping.")
end

if isfield(Config.segmentation, 'mrtim')
    Config.segmentation.mrtim.path.output = [segmentationPath '\mrtim'];
    Info.segmentation.mrtim.finished = ...
    run_submodule(segmentation_mrtim, Config.segmentation.mrtim, "MR-TIM segmentation");
end

%% Model conductivity
if isfield(Config.model, 'fieldtrip')
    Info.model.fieldtrip.finished = true;
    Config.model.fieldtrip.path.output = [modelPath '\fieldtrip'];
    Info.model.fieldtrip.finished = ...
    run_submodule(model_fieldtrip, Config.model.fieldtrip, "FieldTrip conductivity modeling");
end

if isfield(Config.model, 'brainstorm')
    % TODO implement
    warning("Conductivity modeling with Brainstorm is not yet implemented. Skipping.")
end

%% Save additional files
save([outputPath '\config'],'Config');
save([outputPath '\info'],'Info');

end

