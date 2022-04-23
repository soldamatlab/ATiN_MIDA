function [vector] = make_column(vector)
if ~iscolumn(vector)
    vector = vector';
end
end

