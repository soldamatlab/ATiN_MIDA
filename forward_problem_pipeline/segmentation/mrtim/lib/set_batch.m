function [Config] = set_batch(Config)
TYPE_ERROR = "[Config.batch] has to be either struct / struct in a cell or path to a '.mat' file containing a 'matlabbatch' var of the same type.";

batch = Config.batch;
if ischar(convertStringsToChars(batch))
    load(batch, 'matlabbatch');
    if iscell(matlabbatch)
        Config.batch = matlabbatch;
    elseif isstruct(matlabbatch)
        Config.batch = {matlabbatch};
    else
        error(TYPE_ERROR);
    end
elseif iscell(batch)
elseif isstruct(batch)
    Config.batch = {batch};
else
    error(TYPE_ERROR)
end
end

