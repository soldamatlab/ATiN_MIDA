function [GWR, GWRb, GWRc] = get_gray_white_ratio(Config, mriSegmented)
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
GWR = masks_ratio(gray, white);
%% MASKS_RATIO return mask1 / mask2 absolute volume

%% Compute for brain and cerebrum alone
if Config.method == "mrtim" && Config.nLayers == 12
    Config.part = 'brain';
    grayBrain = get_gray(Config, mriSegmented);
    whiteBrain = get_white(Config, mriSegmented);
    GWRb = masks_ratio(grayBrain, whiteBrain);
    
    Config.part = 'cerebrum';
    grayCerebrum = get_gray(Config, mriSegmented);
    whiteCerebrum = get_white(Config, mriSegmented);
    GWRc = masks_ratio(grayCerebrum, whiteCerebrum);
end
end
