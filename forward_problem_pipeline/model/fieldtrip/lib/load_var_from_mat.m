function [var] = load_var_from_mat(varName, path)
data = load(path);
if isfield(data, varName)
    var = data.(varName);
else
    error(["File '" path "' does not contain variable named '" varName "'."])
end
end

