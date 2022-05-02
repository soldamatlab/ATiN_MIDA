function [Config, suffix] = check_seg_config(Config, segName)
check_required_field(Config, segName);
check_required_field(Config.(segName), 'prepro');
check_required_field(Config.(segName), 'segmentation');
check_required_field(Config.(segName), 'method');
check_required_field(Config.(segName), 'nLayers');
suffix = '';
if isfield(Config.(segName), 'suffix') && ~isempty(Config.(segName).suffix)
    Config.(segName).suffix = char(Config.(segName).suffix);
    suffix = ['_' Config.(segName).suffix];
end
if ~isfield(Config.(segName), 'colormap')
    colormap = get_colormap(Config.(segName));
    if ~isempty(colormap)
        Config.(segName).colormap = colormap;
    end
end
end

