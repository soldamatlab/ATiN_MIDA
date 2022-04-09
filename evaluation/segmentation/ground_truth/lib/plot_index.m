function [fig] = plot_index(Config, data)
%% Config
if ~isfield(Config, 'method')
    method = 'segmentation';
elseif Config.method == "fieldtrip"
    method = 'FieldTrip';
elseif Config.method == "mrtim"
    method = 'MR-TIM';
else
    method = Config.method;
end

visualize = true;
if isfield(Config, 'visualize')
    visualize = Config.visualize;
end

%% Plot
fig = figure();
if isfield(Config, 'label')
    heatmap(Config.label, Config.label, data)
else
    heatmap(data)
end
xlabel('SCI')
ylabel(method)
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

