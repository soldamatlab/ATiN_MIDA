function [cellArray] = assign_all_struct_cells(cellArray, field, value)
% CELLSTRUCT_ASSIGNALL works only for 1-dimensional cell arrays.
fields = split(field, '.');
if ~iscell(fields)
    fields = mat2cell(fields);
end
nFields = length(fields);

for c = 1:length(cellArray)
    %% Calculate how many fields are already existing
    existing = 0;
    S = cellArray{c};
    for f = 1:nFields
        if isfield(S, fields{f})
            existing = existing + 1;
        else
            break
        end
        S = S.(fields{f});
    end
    if existing == nFields
        existing = existing - 1; % overwrite the existing value
    end
    
    %% Get the non-existing part of structure tree
    prevS = value;
    for f = nFields:-1:existing+2
        S = struct;
        S.(fields{f}) = prevS;
        prevS = S;
    end
    
    %% Recursively add the previous structure tree to its parent
    for target = existing:-1:0
        S = cellArray{c};
        for f = 1:target
            S = S.(fields{f});
        end
        S.(fields{target+1}) = prevS;
        prevS = S;
    end
    cellArray{c} = prevS;
end
end
