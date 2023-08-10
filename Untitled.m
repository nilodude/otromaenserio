clear, clc, close all;
fs=44100;
fMax=fs/2;
Nfft= 256;
numValues = Nfft/2;
binWidth = fs/Nfft;
% bins = (0:numValues).*(fMax/numValues);
bins = (1:numValues).*binWidth;

% after removing >20kHz, length is Nfft/2 -1
bins = bins(bins<20000);

logBins = log10(bins);
% figure,stem(logBins,logBins)

finalBins = 1920*logBins/max(logBins);
figure, stem(finalBins,finalBins)

% logs=logspace(0,log10(20000),128);
% figure; semilogx(logs, logs);
% 
% logs = 10.^linspace(0,log10(20000),128);
% figure; semilogx(logs, logs);
% 
% grid on;