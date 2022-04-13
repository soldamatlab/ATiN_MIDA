function [fig] = plot_index(Config, data)
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
caxis([0 1])
xlabel(method2)
ylabel(method1)
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

