function [var] = load_var_from_mat(varName, path)
data = load(path);
if isfield(data, varName)
    var = data.(varName);
else
    error("File '%s' does not contain variable named '%s'.", path, varName)
end
end

