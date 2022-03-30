function [Struct] = rm_field_data(Struct, fieldName, varName)
if ~isfield(Struct, fieldName)
    warning("Struct has no field '%s'.", fieldName)
    return
end

if exist('varName','var')
    Struct.(fieldName) = sprintf("removed [%s]", varName);
else
    Struct.(fieldName) = sprintf("removed [%s]", fieldName);
end
end

