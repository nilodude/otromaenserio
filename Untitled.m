clear, clc, close;
fs=44100;
fMax=fs/2;
Nfft= 256;
numValues = Nfft/2;
binWidth = fs/Nfft;
% bins = (0:numValues).*(fMax/numValues);
bins = (0:numValues).*binWidth;

% after removing >20kHz, length is Nfft/2 -1
bins = bins(bins<20000);
logBins = log10(bins);
stem(logBins,logBins)
logBins = 1920*logBins/max(logBins)


% logs=logspace(0,log10(20000),128);
% figure; semilogx(logs, logs);
% 
% logs = 10.^linspace(0,log10(20000),128);
% figure; semilogx(logs, logs);
% 
% grid on;