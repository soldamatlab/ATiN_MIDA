function [sourceRoot] = addpath_source()
%% Define toolbox paths here:
FIELDTRIP_PATH = [matlabroot '\toolbox\fieldtrip'];
SPM_PATH = [matlabroot '\toolbox\spm12'];
MRTIM_PATH = [SPM_PATH '\toolbox\MRTIM'];

%%
addpath(FIELDTRIP_PATH);
ft_defaults

addpath(SPM_PATH);

addpath(MRTIM_PATH);

sourceRoot = fileparts(mfilename('fullpath'));
addpath(genpath(sourceRoot));
end
