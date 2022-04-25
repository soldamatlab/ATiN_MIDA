function [evaluationTable] = plot_evaluation_table(Config, evaluation)
% PLOT_EVALUATION_TABLE
% Required:
%   Config.method
%   Config.SNR
%   Config.SNRnames
%
% Optional:
%   Config.save
%   Config.verbose  = logical, default = true

%% Config
check_required_field(Config, 'method');
method = Config.method;
nMethod = length(method);

check_required_field(Config, 'SNR');
SNR = Config.SNR;
nSNR = length(SNR);

check_required_field(Config, 'SNRnames');
SNRnames = Config.SNRnames;


verbose = true; % default
if isfield(Config, 'verbose')
    verbose = Config.verbose;
end

%% Create Table
nCombinations = nMethod * nSNR;
ED1_x_mean = NaN(nCombinations, 1);
ED1_y_mean = NaN(nCombinations, 1);
ED1_z_mean = NaN(nCombinations, 1);
ED1_x_STD = NaN(nCombinations, 1);
ED1_y_STD = NaN(nCombinations, 1);
ED1_z_STD = NaN(nCombinations, 1);
ED2_mean = NaN(nCombinations, 1);
ED2_STD = NaN(nCombinations, 1);
for m = 1:nMethod
    for s = 1:nSNR
        idx = (m-1)*nSNR + s;
        ED1_x_mean(idx) = evaluation.(method{m}).(SNRnames{s}).ed1mean(1);
        ED1_y_mean(idx) = evaluation.(method{m}).(SNRnames{s}).ed1mean(2);
        ED1_z_mean(idx) = evaluation.(method{m}).(SNRnames{s}).ed1mean(3);
        ED1_x_STD(idx) = evaluation.(method{m}).(SNRnames{s}).ed1std(1);
        ED1_y_STD(idx) = evaluation.(method{m}).(SNRnames{s}).ed1std(2);
        ED1_z_STD(idx) = evaluation.(method{m}).(SNRnames{s}).ed1std(3);
        
        ED2_mean(idx) = evaluation.(method{m}).(SNRnames{s}).ed2mean;
        ED2_STD(idx) = evaluation.(method{m}).(SNRnames{s}).ed2std;
    end
end
method = string(method);
method = repelem(method, nSNR);
method = make_column(method);
SNR = make_column(SNR);
SNR = repmat(SNR, nMethod, 1);
evaluationTable = table(method, SNR, ED1_x_mean, ED1_x_STD, ED1_y_mean, ED1_y_STD, ED1_z_mean, ED1_z_STD, ED2_mean, ED2_STD);

%% Display & Save
if verbose
    disp(evaluationTable)
end
if isfield(Config, 'save')
    save(Config.save, 'evaluationTable');
end
end

