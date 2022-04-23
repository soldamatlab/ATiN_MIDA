function [sourceTemplate] = get_source_template(sourcemodel)
%% GET_SOURCE_TEMPLATE
%  Adopted from 'ATiN_RATESI_Frontiers2021_project' by Stanislav Jiricek.

check_required_field(sourcemodel, 'inside');
sourceTemplate = NaN(length(sourcemodel.inside),1); % Template of source space for reliability maps 
sourceTemplate(sourcemodel.inside) = 0; % Template of source space for reliability maps 
end
