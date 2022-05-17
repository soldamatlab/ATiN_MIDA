%% Init
clear variables
close all
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'S:\BP_MIDA'; % PC-MATOUS
Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote

Path.data.root = [Path.root '\data'];
Path.data.BINO = [Path.data.root '\BINO'];
Path.output.root = [Path.root '\analysis'];
Path.output.BINO = [Path.output.root '\BINO'];

ALIGNED = 'aligned2';

output = '\\PC-matous\BP_MIDA\results\stimulation\BINO';
output = create_output_folder(output, false, false);

% common mri to align all maps to:
Path.mriTarget = '\\PC-matous\BP_MIDA\analysis\BINO\S01\mri_common.mat';
MRI_TARGET_VAR_NAME = 'mriCommon';

evals = cell(1);
evals{1} = 'fieldtrip3_anatomy_prepro';
evals{2} = 'fieldtrip5_anatomy_prepro';
evals{3} = 'mrtim12';
nEvals = length(evals);

fields = cell(1);
fields{1} = 'f3';
fields{2} = 'f5';
fields{3} = 'm12';
if length(fields) ~= nEvals
    error("length(fields) ~= length(evals)")
end

maps = cell(1);
maps{1} = 'houses';
maps{2} = 'faces';
nMaps = length(maps);

%% Get subject paths
subjects = dir([Path.output.BINO '\S*']);
nSubjects = length(subjects);
for s = 1:nSubjects
    Path.(subjects(s).name).root = [subjects(s).folder '\' subjects(s).name];
    Path.(subjects(s).name).stimulation.root =...
        [Path.(subjects(s).name).root '\evaluation\stimulation'];
    
    for e = 1:nEvals
        Path.(subjects(s).name).stimulation.(fields{e}) = [Path.(subjects(s).name).stimulation.root '\' evals{e}];
    end
    
    Path.(subjects(s).name).mriPrepro =...
        [subjects(s).folder '\' subjects(s).name '\segmentation\mrtim12\anatomy_prepro.nii'];
end

%% Calculate dists for each subject
mriCommon = load_mri_anytype(Path.mriTarget, MRI_TARGET_VAR_NAME);
positions = struct;
for m = 1:nMaps
    positions.(maps{m}) = struct;
    for e = 1:nEvals
        positions.(maps{m}).(fields{e}) = NaN(nSubjects, 3);
    end
end
for s = 1:nSubjects
    %% Load aligned sources
    for e = 1:nEvals
        evalPath = [Path.(subjects(s).name).stimulation.(fields{e}) '\' ALIGNED '\source_interp.mat'];
        source = load_var_from_mat('sourceInterp', evalPath);
        
        for m = 1:nMaps
            map = source.(maps{m});
            [~, idx] = max(map(:));
            [idx1, idx2, idx3] = ind2sub(size(map), idx);
            positions.(maps{m}).(fields{e})(s,:) = [idx1, idx2, idx3];
        end
    end
end

for m = 1:nMaps
    for e = 1:nEvals
        if sum(isnan(positions.(maps{m}).(fields{e})), 'all')
            error("'positions.%s.%s' and posibly other fields include NaN values.", maps{m}, fields{e})
        end
    end
end 

%% Calculate dists
pairs = nchoosek(1:nEvals, 2);
nPairs = size(pairs, 1);
for p = 1:nPairs
    idx1 = pairs(p,1);
    idx2 = pairs(p,2);
    fieldName = [fields{idx1} '_diff_' fields{idx2}];
    for m = 1:nMaps
        positions.(maps{m}).(fieldName).dists        = NaN(nSubjects, 4);
        axisDists = positions.(maps{m}).(fields{idx1}) - positions.(maps{m}).(fields{idx2});
        positions.(maps{m}).(fieldName).dists(:,4)   = sqrt(sum((axisDists.^2),2));
        positions.(maps{m}).(fieldName).dists(:,1:3) = axisDists;
        if sum(isnan(positions.(maps{m}).(fieldName).dists), 'all')
            error("'positions.%s.%s.dists' conatins NaN values.", maps{m}, fieldName)
        end
    end
    
    positions.(maps{m}).(fieldName).mean = mean(positions.(maps{m}).(fieldName).dists, 1);
    positions.(maps{m}).(fieldName).std  = std(positions.(maps{m}).(fieldName).dists, 0, 1);
end
save([output '\max_poistions'], 'positions');
    