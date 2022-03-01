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

%% Segmentation
% TODO add try catch blocks
if isfield(Config.segmentation, 'fieldtrip')
    Config.segmentation.fieldtrip.path.output = [segmentationPath '\fieldtrip'];
    segmentation_fieldtrip(Config.segmentation.fieldtrip);
end

if isfield(Config.segmentation, 'brainstorm')
    % TODO not implemented
    warning("Segmentation with Brainstorm is not yet implemented. Skipping.")
end

if isfield(Config.segmentation, 'mrtim')
    Config.segmentation.mrtim.path.output = [segmentationPath '\mrtim'];
    segmentation_mrtim(Config.segmentation.mrtim);
end

%% Model conductivity
% TODO add try catch blocks
if isfield(Config.model, 'fieldtrip')
    Config.model.fieldtrip.path.output = [modelPath '\fieldtrip'];
    model_fieldtrip(Config.segmentation.fieldtrip);
end

if isfield(Config.model, 'brainstorm')
    % TODO not implemented
    warning("Conductivity modeling with Brainstorm is not yet implemented. Skipping.")
end

%% Save additional files
save([outputPath '\config'],'Config');

end

