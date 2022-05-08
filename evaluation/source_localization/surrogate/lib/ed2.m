function [ed2] = ed2(Config)
% ED2
% TODO doc
%
% Required:
%   Config.sourcemodel  = FieldTrip structure
%
%   Config.truePosition
%    or
%   Config.dipoleIdx
%
%   Config.dipoleValues
%    or
%   Config.source

%% Config
check_required_field(Config, 'sourcemodel');
sourcemodel = Config.sourcemodel;

if isfield(Config, 'truePosition')
    truePosition = Config.truePosition;
elseif isfield(Config, 'dipoleIdx')
    truePosition = sourcemodel.pos(Config.dipoleIdx,:);
else
    error("[Config] must include 'truePosition' or 'dipoleIdx' field.");
end

if isfield(Config, 'dipoleValues')
    values = Config.dipoleValues;
elseif isfield(Config, 'source')
    check_required_field(Config.source, 'avg');
    check_required_field(Config.source.avg, 'pow');
    values = Config.source.avg.pow;
else
    error("[Config] must include 'dipoleValues' or 'source' field.");
end

%% Get Local Maxima
cfg = struct;
cfg.val = values;
cfg.pos = sourcemodel.pos;
cfg.dim = sourcemodel.dim;
[grid, ~] = source2grid(cfg);
grid(isnan(grid)) = min(grid,[],'all') - 1; % convert NaNs & ensure NaNs are not local maxima
isLocmax = imregionalmax(grid, 26); % 26 is default
isLocmax = reshape(isLocmax, [numel(isLocmax),1]);

%% Compute
locmaxPositions = sourcemodel.pos(isLocmax, :);
locmaxDists = vecnorm(truePosition - locmaxPositions,2,2);
locmaxValues = make_column(values(isLocmax));
locmaxWeights = locmaxValues / max(locmaxValues);
ed2 = sum(locmaxWeights .* locmaxDists);
end
