function [] = check_required_field(structure, field)
if ~isfield(structure, field)
    error("'%s' cannot be empty!", field)
end
end

