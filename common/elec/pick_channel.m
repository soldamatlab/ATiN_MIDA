function [data] = pick_channel(Config, data)
% PICK_CHANNEL
%
% Required:
%   data            =             FiedTrip elec struct or EEG data struct
%                     Use Config.datatype:    'elec'         'data'
%   Config.channel  = index or array of indexes
%
% Optional:
%   Config.datatype = choose from ['elec', 'data'], default is 'elec'
%

%% Config
check_required_field(Config, 'channel')
channel = Config.channel;

datatype = 'elec';
if isfield(Config, 'datatype')
    if strcmp(Config.datatype, 'elec') || strcmp(Config.datatype, 'data')
        datatype = Config.datatype;
    else
        warning("[Config.datatype] value ('%s') not recognized. Using the default ('%s').", Config.datatype, datatype)
    end
end

%% Pick data fields
if strcmp(datatype, 'data')
    if isfield(data, 'label')
        data.label = data.label(channel);
    end
    if isfield(data, 'trial')
        trial = data.trial{1};
        data.trial{1} = trial(channel, :);
    end
    if isfield(data, 'elec')
        elec = data.elec;
    else
        return
    end
    
elseif strcmp(datatype, 'elec')
    elec = data;
end

%% Pick elec fields
if isfield(elec, 'chanpos')
    elec.chanpos = elec.chanpos(channel,:);
end
if isfield(elec, 'elecpos')
    elec.elecpos = elec.elecpos(channel,:);
end
if isfield(elec, 'chantype')
    elec.chantype = elec.chantype(channel);
end
if isfield(elec, 'chanunit')
    elec.chanunit = elec.chanunit(channel);
end
if isfield(elec, 'label')
    elec.label = elec.label(channel);
end
if isfield(elec, 'tra')
    tra = full(elec.tra);
    elec.tra = sparse(tra(channel, channel));
end

%% Return
if strcmp(datatype, 'data')
    data.elec = elec;
elseif strcmp(datatype, 'elec')
    data = elec;
end
end
