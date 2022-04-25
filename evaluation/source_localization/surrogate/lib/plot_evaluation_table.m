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
xMean = NaN(nCombinations, 1);
yMean = NaN(nCombinations, 1);
zMean = NaN(nCombinations, 1);
xSTD = NaN(nCombinations, 1);
ySTD = NaN(nCombinations, 1);
zSTD = NaN(nCombinations, 1);
for m = 1:nMethod
    for s = 1:nSNR
        idx = (m-1)*nSNR + s;
        xMean(idx) = evaluation.(method{m}).(SNRnames{s}).ed1mean(1);
        yMean(idx) = evaluation.(method{m}).(SNRnames{s}).ed1mean(2);
        zMean(idx) = evaluation.(method{m}).(SNRnames{s}).ed1mean(3);
        xSTD(idx) = evaluation.(method{m}).(SNRnames{s}).ed1std(1);
        ySTD(idx) = evaluation.(method{m}).(SNRnames{s}).ed1std(2);
        zSTD(idx) = evaluation.(method{m}).(SNRnames{s}).ed1std(3);
    end
end
method = string(method);
method = repelem(method, nSNR);
method = make_column(method);
SNR = make_column(SNR);
SNR = repmat(SNR, nMethod, 1);
evaluationTable = table(method, SNR, xMean, xSTD, yMean, ySTD, zMean, zSTD);

%% Display & Save
if verbose
    disp(evaluationTable)
end
if isfield(Config, 'save')
    save(Config.save, 'evaluationTable');
end
end

