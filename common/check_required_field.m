function [] = check_required_field(structure, field)
if ~isfield(structure, field)
    error("'%s' has to contain field '%s'!", inputname(1), field)
end
end

