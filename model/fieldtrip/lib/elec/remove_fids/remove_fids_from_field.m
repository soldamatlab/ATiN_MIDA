function [elecStruct] = remove_fids_from_field(elecStruct, fieldName, twoDim)
if ~isfield(elecStruct, fieldName)
    return
end

field = elecStruct.(fieldName);

if exist('twoDim', 'var') && twoDim
    field = field(4:end,4:end);
else
    field = field(4:end,:);
end

elecStruct.(fieldName) = field;
end

