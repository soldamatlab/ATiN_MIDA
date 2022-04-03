function [elec] = remove_fids(elec)
elec = remove_fids_from_field(elec, 'chanpos');
elec = remove_fids_from_field(elec, 'chantype');
elec = remove_fids_from_field(elec, 'chanunit');
elec = remove_fids_from_field(elec, 'elecpos');
elec = remove_fids_from_field(elec, 'label');
elec = remove_fids_from_field(elec, 'tra', true);
if isfield(elec, 'cfg')
    elec.cfg = remove_fids_from_field(elec.cfg, 'channel');
end
end

