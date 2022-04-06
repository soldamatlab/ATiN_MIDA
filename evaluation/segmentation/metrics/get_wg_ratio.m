function [wgRatio] = get_wg_ratio(Config, mriSegmented)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\..\..\..\common']));
addpath([wd '/lib']);

%% Config
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');
mriSegmented = load_mri_anytype(mriSegmented);

%% Compute
white = get_white(Config, mriSegmented);
gray = get_gray(Config, mriSegmented);
absWhite = sum(white, 'all');
absGray = sum(gray, 'all');
wgRatio = absWhite / absGray;
end
