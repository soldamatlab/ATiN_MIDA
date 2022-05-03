
function [refIdx] = find_vref(data)
%% Settings
refLabel = {'VREF', 'EREF'}; % case insensitive

%% Find
refIdx = NaN;
if isfield(data, 'label')
    if iscell(data.label)
        for l = 1:length(data.label)
            for r = 1:length(refLabel)
                if strcmpi(data.label{l}, refLabel{r})
                    refIdx = l;
                    break;
                end
            end
            if ~isnan(refIdx)
                break;
            end
        end
    else
        warning("'eegData.label' is not a cell array.")
    end
end
if ~rereference
    warning("Voltage reference not found.")
end
end
