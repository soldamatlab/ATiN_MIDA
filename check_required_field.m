function [is_field] = check_required_field(structure, field)
if ~isfield(structure, field)
    fprintf("'%s' cannot be empty!\n", field)
    is_field = false;
    return
end

is_field = true;
return
end

