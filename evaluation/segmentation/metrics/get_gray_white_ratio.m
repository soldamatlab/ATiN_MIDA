function [gwRatio] = get_gray_white_ratio(Config, mriSegmented)
%% Import
wd = fileparts(mfilename('fullpath'));
addpath(genpath([wd '\..\..\..\common']));
addpath([wd '/lib']);

%% Config
check_required_field(Config, 'method');
check_required_field(Config, 'nLayers');
mriSegmented = load_mri_anytype(mriSegmented);

%% Compute
gray = get_gray(Config, mriSegmented);
white = get_white(Config, mriSegmented);
absGray = sum(gray, 'all');
absWhite = sum(white, 'all');
gwRatio = absGray / absWhite;
end
