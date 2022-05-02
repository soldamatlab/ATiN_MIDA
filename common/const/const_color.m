Color = struct;

%% Define colors
linesMap = lines(7);
prismMap = prism(6);
springMap = spring(3);
parulaMap = parula(6);
grayMap = gray(5);

background = linesMap(1,:); % blue
brainGrayMatter = linesMap(3,:); % orange
brainWhiteMatter = springMap(3,:); % yellow
cerebrumGrayMatter = summer(1); % dark green
cerebrumWhiteMatter = linesMap(5,:); % green
brainstem = prismMap(1,:); % red
csf = linesMap(7,:); % dark red
bone1 = white(1);
bone2 = grayMap(4,:);
soft1 = linesMap(4,:); % purple
soft2 = prismMap(6,:); % violet
eyes = linesMap(6,:); % light blue
skin = springMap(2,:); % pink

%% Original order of tissues:
Color.map.original.fieldtrip3 = [...
    background;
    brainGrayMatter;
    bone1;
    soft1;
];

Color.map.original.fieldtrip5 = [...
    background;
    brainGrayMatter;
    brainWhiteMatter;
    csf;
    bone1;
    soft1;
];

Color.map.original.mrtim12 = [...
    background;
    brainGrayMatter;
    cerebrumGrayMatter;
    brainWhiteMatter;
    cerebrumWhiteMatter;
    brainstem;
    csf;
    bone1;
    bone2;
    soft2;
    soft1;
    eyes;
    skin;
];

Color.map.original.sci8 = [...
    eyes;
    eyes;
    brainGrayMatter;
    brainWhiteMatter;
    csf;
    soft2;
    bone1;
    soft1;
    background;
];

%% ft_dataype_segmentation order of tissues:
Color.map.alphabetical.fieldtrip3 = [...
    Color.map.original.fieldtrip3(1,:);
    Color.map.original.fieldtrip3(4,:);
    Color.map.original.fieldtrip3(3,:);
    Color.map.original.fieldtrip3(2,:);
];

Color.map.alphabetical.fieldtrip5 = [...
    Color.map.original.fieldtrip5(1,:);
    Color.map.original.fieldtrip5(4,:);
    Color.map.original.fieldtrip5(2,:);
    Color.map.original.fieldtrip5(6,:);
    Color.map.original.fieldtrip5(5,:);
    Color.map.original.fieldtrip5(3,:);
];

Color.map.alphabetical.mrtim12 = [...
    Color.map.original.mrtim12(1,:);
    Color.map.original.mrtim12(2,:);
    Color.map.original.mrtim12(6,:);
    Color.map.original.mrtim12(4,:);
    Color.map.original.mrtim12(3,:);
    Color.map.original.mrtim12(9,:);
    Color.map.original.mrtim12(7,:);
    Color.map.original.mrtim12(5,:);
    Color.map.original.mrtim12(12,:);
    Color.map.original.mrtim12(11,:);
    Color.map.original.mrtim12(13,:);
    Color.map.original.mrtim12(10,:);
    Color.map.original.mrtim12(8,:);
];

Color.map.alphabetical.sci8 = [...
    Color.map.original.sci8(8,:);
    Color.map.original.sci8(8,:);
    Color.map.original.sci8(6,:);
    Color.map.original.sci8(4,:);
    Color.map.original.sci8(1,:);
    Color.map.original.sci8(2,:);
    Color.map.original.sci8(5,:);
    Color.map.original.sci8(7,:);
    Color.map.original.sci8(3,:);
];

%% Defaults
Color.map.fieldtrip3 = Color.map.original.fieldtrip3;
Color.map.fieldtrip5 = Color.map.original.fieldtrip5;
Color.map.mrtim12 = Color.map.original.mrtim12;
Color.map.sci8 = Color.map.original.sci8;

%% Cleanup
clear linesMap prismMap parulaMap springMap grayMap
