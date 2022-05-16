%% Init
clear variables
close all
addpath_source;

%% Paths & Config - Set manually
% Local paths:
%Path.root = 'S:\BP_MIDA'; % PC-MATOUS
Path.root = '\\Pc-matous\bp_mida'; % PC-MATOUS remote

Path.data.root = [Path.root '\data'];
Path.data.NUDZ = [Path.data.root '\MR'];
Path.data.BINO = [Path.data.root '\BINO'];
Path.output.root = [Path.root '\analysis'];
Path.output.NUDZ = [Path.output.root '\NUDZ'];
Path.output.BINO = [Path.output.root '\BINO'];

% dataset:
dataset = 'NUDZ';
%dataset = 'BINO';

% output:
output = [Path.root '\results\segmentation\' dataset];

% Segmentations:
methods =  {'fieldtrip',      'fieldtrip',                 'mrtim'};
layers =   [ 3,                5,                           12    ];
suffixes = {'anatomy_prepro', 'anatomy_prepro',            ''     };

methods = convertStringsToChars(methods);
suffixes = convertStringsToChars(suffixes);
[segmentations, nSegmentations] = get_segmentation_names(methods, layers, suffixes);

%% Find subjects
if strcmp(dataset, 'NUDZ')
    subjects = dir([Path.output.NUDZ '\*_*_*']);
elseif strcmp(dataset, 'BINO')
    subjects = dir([Path.output.BINO '\S*']);
else
    error("Unknown dataset")
end
nSubjects = length(subjects);
for s = 1:nSubjects
    for m = 1:nSegmentations
        Path.(subjects(s).name).segcompare =...
            [subjects(s).folder '\' subjects(s).name '\evaluation\compare_segmentations\'];
    end
end

%% Calculate Medians and IRQs
pairs = nchoosek(1:nSegmentations, 2);
nPairs = size(pairs, 1);
for p = 1:nPairs
    idx1 = pairs(p,1);
    idx2 = pairs(p,2);
    eval1 = [segmentations{idx1} '_' segmentations{idx2}];
    eval2 = [segmentations{idx2} '_' segmentations{idx1}];
    [outputPath, imgPath] = create_output_folder([output '\' eval1], false);
    data = struct;
    for s = 1:nSubjects
        %% Load Indexes
        path1 = [Path.(subjects(s).name).segcompare '\' eval1 '\' eval1 '_result.mat'];
        path2 = [Path.(subjects(s).name).segcompare '\' eval2 '\' eval2 '_result.mat'];
        Result1 = load_var_from_mat('Result', path1);
        Result2 = load_var_from_mat('Result', path2);
        
        if s == 1
            dim = size(Result1.dice);
            data.so1     = NaN([dim nSubjects]);
            data.so2     = NaN([dim nSubjects]);
            data.dice    = NaN([dim nSubjects]);
            data.jaccard = NaN([dim nSubjects]);
            segmentation1 = load_var_from_mat('segmentation1', path1);
            clear segmentation1
        end
        
        data.so1(:,:,s)     = Result1.spatialOverlap;
        data.so2(:,:,s)     = Result2.spatialOverlap;
        data.dice(:,:,s)    = Result1.dice;
        data.jaccard(:,:,s) = Result1.jaccard;
    end
    
    %% Calculate Median and IQR
    if sum(isnan(data.so1))
        error("'data.so1' contains NaN values.")
    end
    if sum(isnan(data.so2))
        error("'data.so2' contains NaN values.")
    end
    if sum(isnan(data.dice))
        error("'data.dice' contains NaN values.")
    end
    if sum(isnan(data.jaccard))
        error("'data.jaccard' contains NaN values.")
    end

    index = struct;
    index.so1.median     = median(data.so1, 3);
    index.so2.median     = median(data.so2, 3);
    index.dice.median    = median(data.dice, 3);
    index.jaccard.median = median(data.jaccard, 3);
    index.so1.iqr     = iqr(data.so1, 3);
    index.so2.iqr     = iqr(data.so2, 3);
    index.dice.iqr    = iqr(data.dice, 3);
    index.jaccard.iqr = iqr(data.jaccard, 3);
    save([outputPath '\median_index'], 'index');
    
    %% Plot
    if dim(1) == 3
        tissuelabel = {'Brain', 'Other', 'BG'};
    elseif dim(1) == 5
        tissuelabel = {'GM', 'WM', 'CSF', 'Other', 'BG'};
    end
    
    cfg = struct;
    cfg.method1 = methods{idx1};
    cfg.nLayers1 = layers(idx1);
    cfg.method2 = methods{idx2};
    cfg.nLayers2 = layers(idx2);
    cfg.label = tissuelabel;
    cfg.visualize = false;

    cfg.title = 'Spatial Overlap index Meadian';
    cfg.save = [imgPath '\spatial_overlap_1_median'];
    plot_index(cfg, index.so1.median);
    cfg.title = 'Spatial Overlap index IQR';
    cfg.save = [imgPath '\spatial_overlap_1_iqr'];
    plot_index(cfg, index.so1.iqr);

    cfg.title = 'Dice index Meadian';
    cfg.save = [imgPath '\dice_median'];
    plot_index(cfg, index.dice.median);
    cfg.title = 'Dice index IQR';
    cfg.save = [imgPath '\dice_iqr'];
    plot_index(cfg, index.dice.iqr);

    cfg.title = 'Jaccard index Meadian';
    cfg.save = [imgPath '\jaccard_median'];
    plot_index(cfg, index.jaccard.median);
    cfg.title = 'Jaccard index IQR';
    cfg.save = [imgPath '\jaccard_iqr'];
    plot_index(cfg, index.jaccard.iqr);
    
    cfg.method1 = methods{idx2};
    cfg.nLayers1 = layers(idx2);
    cfg.method2 = methods{idx1};
    cfg.nLayers2 = layers(idx1);
    
    cfg.title = 'Spatial Overlap index Meadian';
    cfg.save = [imgPath '\spatial_overlap_2_median'];
    plot_index(cfg, index.so2.median);
    cfg.title = 'Spatial Overlap index IQR';
    cfg.save = [imgPath '\spatial_overlap_2_iqr'];
    plot_index(cfg, index.so2.iqr);
    
    %% Boxplot Dice index
    diag = struct;
    dim = size(data.dice);
    diag.so1 = NaN(dim([1,3]));
    for i = 1:dim(1)
        diag.so1(i,:) = data.so1(i,i,:);
    end
    %%
    fig = figure;
    boxplot(diag.so1', tissuelabel)
    title(['Dice index - ' methods{idx1} ' ' num2str(layers(idx1)) ' vs ' methods{idx2} ' ' num2str(layers(idx2))])
    print([imgPath '\dice_boxplot'], '-dpng', '-r300')
    if ~cfg.visualize
        close(fig)
    end
end
