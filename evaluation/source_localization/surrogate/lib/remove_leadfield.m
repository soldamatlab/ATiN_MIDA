function [sourcemodel] = remove_leadfield(sourcemodel)
sourcemodel = rmfield(sourcemodel, 'leadfield');
sourcemodel = rmfield(sourcemodel, 'label');
sourcemodel = rmfield(sourcemodel, 'leadfielddimrod');
end

