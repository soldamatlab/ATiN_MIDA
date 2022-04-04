function [mri] = load_nrrd_mri(filename, Config)
%% Defaults
unit = 'mm';

%% Config
if exist('Config', 'var')
    if isfield(Config, 'unit')
        unit = Config.unit;
    end
end

%% Load .nrrd file
headerInfo = nhdr_nrrd_read(filename, true);

%% Create FieldTrip MRI struct
mri = struct;
mri.dim = headerInfo.sizes;
mri.anatomy = headerInfo.data;
mri.transform = [headerInfo.spacedirections_matrix, headerInfo.spaceorigin];
mri.transform = [mri.transform; [0,0,0,1]];
mri.unit = unit;
end

