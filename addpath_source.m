function [sourceRoot] = addpath_source()
sourceRoot = fileparts(mfilename('fullpath'));
addpath(genpath(sourceRoot));
end
