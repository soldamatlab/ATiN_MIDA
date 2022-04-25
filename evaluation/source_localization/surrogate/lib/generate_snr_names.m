function [SNRnames] = generate_snr_names(SNR)
nSNR = length(SNR);
SNRnames = cell(1, nSNR);
for s = 1:nSNR
    SNRnames{s} = ['snr' num2str(SNR(s))];
end
end

