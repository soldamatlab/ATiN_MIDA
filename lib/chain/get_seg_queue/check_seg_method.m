function [isValid] = check_seg_method(method)
if method == "file" || method == "fieldtrip" || method == "mrtim"
    isValid = true;
else
    warning("Unrecognized segmentation method '%s' will be skipped by modeling submodule.", method);
    isValid = false;
end
end

