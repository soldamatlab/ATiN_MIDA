function [checkedMethod] = check_methods(method, allowedMethods)
checkedMethod = {};
nCheckedMethod = 0;
for m = 1:length(method)
    if ismember(method{m}, allowedMethods)
        nCheckedMethod = nCheckedMethod + 1;
        checkedMethod{nCheckedMethod} = convertStringsToChars(method{m});
    else
        warning("Unsupported method '%s' will be skipped.", method{m})
    end
end
end

