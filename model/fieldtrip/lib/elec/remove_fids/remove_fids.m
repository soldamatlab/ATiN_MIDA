function [elec] = remove_fids(elec)
remove_fids_from_field(elec, 'chanpos');
remove_fids_from_field(elec, 'chantype');
remove_fids_from_field(elec, 'chanunit');
remove_fids_from_field(elec, 'elecpos');
remove_fids_from_field(elec, 'label');
remove_fids_from_field(elec, 'tra');
if isfield(elec, 'cfg')
    remove_fids_from_field(elec.cfg, 'channel');
end
end

