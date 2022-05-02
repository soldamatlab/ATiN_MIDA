%% To Set Manually:
sourceCodeRoot = addpath_source;
%sourceCodeRoot = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\ATiN_MIDA_Matous_project';

fieldtripPath = [matlabroot '\toolbox\fieldtrip'];
spmPath = [matlabroot '\toolbox\spm12'];
mrtimPath = [spmPath '\toolbox\mrtim'];

nudzDataRoot = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\data\MR';
%sciDataRoot = ''; % Not needed if 'ATiN_MIDA_Matous_project\data' folder
                   % is present.
analysisRoot = 'C:\Users\matou\Documents\MATLAB\BP_MIDA\data\analysis';

%% Path structure
Path = struct;

% Source code:
Path.source.root = sourceCodeRoot;
Path.source.common = [Path.source.root '\common'];
Path.source.pipeline = [Path.source.root '\forward_problem_pipeline'];
Path.source.segmentation.root = [Path.source.pipeline '\segmentation'];
Path.source.segmentation.fieldtrip = [Path.source.segmentation.root '\fieldtrip'];
Path.source.segmentation.mrtim = [Path.source.segmentation.root '\mrtim'];
Path.source.model.root = [Path.source.pipeline '\model'];
Path.source.model.fieldtrip = [Path.source.model.root '\fieldtrip'];
Path.source.external = [Path.source.root '\external'];
Path.source.nrrd = [Path.source.external '\nrrd_read_write_rensonnet'];

% Toolboxes:
Path.toolbox.fieldtrip = fieldtripPath;
Path.toolbox.spm = spmPath;
Path.toolbox.mrtim = mrtimPath;

% Data:
Path.data.nudz = nudzDataRoot;
if exist('sciDataRoot', 'var')
    Path.data.sci.root = sciDataRoot;
else
    Path.data.sci.root = [Path.source.root '\data\SCI'];
end
Path.data.sci.segmentation = [Path.data.sci.root '\Segmentation\HeadSegmentation.nrrd'];
Path.data.sci.prepro = [Path.data.sci.root '\T1\T1_Corrected.nrrd'];

Path.data.elec.HydroCel = [Path.source.model.root '\data\elec_template\GSN-HydroCel-257.sfp'];

%% Clear
clear sourceCodeRoot fieldtripPath spmPath mrtimPath nudzDataRoot sciDataRoot analysisRoot
