function [elecStruct] = remove_fids_from_field(elecStruct, fieldName)
if ~isfield(elecStruct, fieldName)
    return
end

field = elecStruct.(fieldName);
field = field(4:end,4:end);
elecStruct.(fieldName) = field;
end

