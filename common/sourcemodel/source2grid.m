function [grid, pos] = source2grid(Config)
%% Config
if isfield(Config, 'source')
    source = Config.source;
    param = 'pow'; % default
    if isfield(Config, 'param')
        param = Config.param;
    end
else
    check_required_field(Config, 'val');
    check_required_field(Config, 'pos');
    check_required_field(Config, 'dim');
end

%% Transform
if isfield(Config, 'source')
    grid = reshape(source.avg.(param), source.dim);
    pos = positions2indexes(source.pos);
else
    grid = reshape(Config.val, Config.dim);
    pos = positions2indexes(Config.pos);
end
end
