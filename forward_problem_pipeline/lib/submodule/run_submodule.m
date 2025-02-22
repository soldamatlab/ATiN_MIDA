function [finished] = run_submodule(submodule, input, name)
if  ~exist('name', 'var')
    name = inputname(1);
end
fprintf("Running: %s\n", name);

try
    submodule(input);
catch submoduleError
    finished = false;
    submodule_error_warning(name, submoduleError)
    return
end
finished = true;
end
