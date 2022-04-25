function [parameter] = choose_value_parameter(valueParameter, method)
% CHOOSE_VALUE_PARAMETER
%   [parameter] = choose_value_parameter(valueParameter, method)
%
%   valueParameter = struct
%   method         = string
%
%   parameter      = string
%
if isfield(valueParameter, method)
    parameter = valueParameter.(method);
else
    parameter = valueParameter.default;
end
end

