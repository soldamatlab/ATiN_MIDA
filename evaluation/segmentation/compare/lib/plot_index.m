function [fig] = plot_index(Config, data)
% PLOT_INDEX
%
% Required:
%   TODO
%
% Optional:
%   Config.omit = cell array, include all tissue labels to omit
%                 while plotting results (i.e. {'gray', 'white'})
%   TODO
%% Config
if ~isfield(Config, 'method1')
    method1 = 'segmentation';
elseif Config.method1 == "fieldtrip"
    method1 = 'FieldTrip';
elseif Config.method1 == "mrtim"
    method1 = 'MR-TIM';
else
    method1 = Config.method1;
end
if isfield(Config, 'nLayers1')
    method1 = [char(method1) ' ' num2str(Config.nLayers1)]; 
end

if ~isfield(Config, 'method2')
    method2 = 'segmentation';
elseif Config.method2 == "fieldtrip"
    method2 = 'FieldTrip';
elseif Config.method2 == "mrtim"
    method2 = 'MR-TIM';
else
    method2 = Config.method2;
end
if isfield(Config, 'nLayers2')
    method2 = [char(method2) ' ' num2str(Config.nLayers2)]; 
end

if isfield(Config, 'omit')
    if isfield(Config, 'label')
        for o = 1:length(Config.omit)
            Config.omit{o} = convertStringsToChars(Config.omit{o});
        end
        newLabel = {};
        for l = 1:length(Config.label)
            if ismember(Config.label{l}, Config.omit)
                data = data([1:l-1,l+1:end], [1:l-1,l+1:end]);
            else
                newLabel{length(newLabel)+1} = Config.label{l};
            end
        end
        Config.label = newLabel;
    else
        warning("'Config.label' is required for 'Config.omit' to work. Selected tissues won't be omitted.")
    end
end

visualize = true;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Plot
data = round(data, 3);
fig = figure();
if isfield(Config, 'label')
    h = heatmap(Config.label, Config.label, data);
else
    h = heatmap(data);
end
%h.FontSize = 15;
caxis([0 1])
xlabel(method1)
ylabel(method2)
if isfield(Config, 'title')
    title(Config.title)
    set(fig, 'Name', Config.title)
end

%% Save
if isfield(Config, 'save')
    print(Config.save, '-dpng', '-r300')
end
if ~visualize
    close(fig)
end
end

