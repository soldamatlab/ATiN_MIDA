function [checkedMethod] = check_methods(method, allowedMethods)
checkedMethod = [];
for m = 1:length(method)
    if ismember(method(m), allowedMethods)
        checkedMethod = [checkedMethod method(m)];
    else
        warning("Unsupported method '%s' will be skipped.", method(m))
    end
end
end

