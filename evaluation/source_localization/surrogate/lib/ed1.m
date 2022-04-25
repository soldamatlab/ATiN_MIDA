function [ed1, shift] = ed1(Config)
% ED1
% Will return multiple values if there are multiple global maximums.
% TODO doc params
%
% Use as
%   [ed1, shift] = ed1(Config)
%
% Required:
%   Config.truePosition     - use for non-FieldTrip inputs,
%   Config.dipolePositions    dipolePostitons and dipoleValues must have
%   Config.dipoleValues       same ordering
%
%   or
%
%   Config.dipoleIdx
%   Config.sourcemodel      - use for FieldTrip-structure inputs
%   Config.source
%
% Optional:
%   Config.returnOne        = logical, if true, only the minimal ed1 is
%                             returned in case of multiple global maximums
%

%% Config
if isfield(Config, 'dipolePositions')
    positions = Config.dipolePositions;
elseif isfield(Config, 'sourcemodel')
    check_required_field(Config.sourcemodel, 'pos');
    positions = Config.sourcemodel.pos;
else
    error("[Config] must include 'dipolePositions' or 'sourcemodel' field.");
end

if isfield(Config, 'truePosition')
    truePosition = Config.truePosition;
elseif isfield(Config, 'dipoleIdx')
    truePosition = positions(Config.dipoleIdx,:);
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

returnOne = false; % default
if isfield(Config, 'returnOne')
    returnOne = Config.returnOne;
end

%% Compute
[~, maxIndices] = max(values);
maxPositions = positions(maxIndices,:);
shift = truePosition - maxPositions;
ed1 = sqrt(sum(shift.^2,2)); % norm of rows

if returnOne
    [ed1, minIdx] = min(ed1);
    shift = shift(minIdx,:);
end
end

