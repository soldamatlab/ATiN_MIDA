function [subDir] = find_in_dir(directory, name, Config)
%% FIND_IN_DIR
%   Required:
%   dir - struct returned by dir() of lenght 1
%   name
%
%   Optional:
%   Config - struct, see below
%   Config.min
%   Config.max - set 0 or false to disable
    parentDir = [directory.folder '\' directory.name];
    subDir = dir([parentDir '\' name]);
    if exist('Config', 'var') && isfield(Config, 'dir') && Config.dir
        subDir = subDir([subDir.isdir]);
    end
    
    min = 1;
    max = 1;
    if exist('Config', 'var')
        if isfield(Config, 'min')
            min = Config.min;
        end
        if isfield(Config, 'max')
            if Config.max
                max = Config.max;
            else
                max = false;
            end
        end
    end
    
    numFiles = length(subDir);
    if numFiles < min
        error("%d file(s) '%s' not found in '%s'. Found %d.", min, name, parentDir, numFiles)
    end
    if max
        if length(subDir) > max
            warning("More than %d '%s' file(s) found in '%s'. Returning first one.", max, name, parentDir)
            subDir = subDir(1);
        end
    end
end

