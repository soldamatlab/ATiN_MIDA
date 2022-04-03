function [] = submodule_error_warning(submodule, submoduleError)
warning("Could not finish '%s' due to the following error.", submodule)
warning("%s", getReport(submoduleError))
end

