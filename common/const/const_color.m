Color = struct;

%% Segmentation colormaps
linesMap = lines(7);
prismMap = prism(6);
springMap = spring(3);
parulaMap = parula(6);
grayMap = gray(5);

Color.map.fieldtrip3 = [...
    linesMap(1,:); % blue
    linesMap(4,:); % purple
    white(1); %grayMap(4,:);
    linesMap(3,:); % orange
];

%Color.map.fieldtrip5 = lines(6);

Color.map.fieldtrip5 = [...
    linesMap(1,:); % blue
    linesMap(7,:); % dark red
    linesMap(3,:); % orange
    linesMap(4,:); % purple
    white(1); %grayMap(4,:);
    springMap(3,:);% yellow
];


%Color.map.mrtim12 =...
%    [
%    linesMap(1,:); % blue
%    linesMap(3,:); % yellow
%    prismMap(1,:); % red
%    springMap(3,:);% yellow
%    linesMap(2,:); % orange
%    linesMap(5,:); % green
%    linesMap(7,:); % dark red
%    autumnMap(9,:);% yellow
%    linesMap(6,:); % blue
%    linesMap(4,:); % purple
%    parulaMap(2,:);% blue
%    prismMap(6,:); % purple
%    summer(1)];    % green

Color.map.mrtim12 = [...
    linesMap(1,:); % blue
    linesMap(3,:); % orange
    prismMap(1,:); % red
    springMap(3,:);% yellow
    summer(1);     % green
    grayMap(4,:);
    linesMap(7,:); % dark red
    linesMap(5,:); % green
    linesMap(6,:); % blue
    linesMap(4,:); % purple
    parulaMap(2,:);% blue
    prismMap(6,:); % purple
    white(1);
];

Color.map.sci8 = [...
    linesMap(1,:); % blue
    linesMap(1,:); % blue
    white(1); %grayMap(4,:);
    linesMap(7,:); % dark red
    linesMap(6,:); % blue
    linesMap(3,:); % orange
    prismMap(6,:); % purple
    linesMap(4,:); % purple
    springMap(3,:);% yellow
];

%% Cleanup
clear linesMap prismMap parulaMap springMap grayMap
