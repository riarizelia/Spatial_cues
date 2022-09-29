% Create a clean spatialized signal for Normal Hearing (NH)

fs = 16000; % sampling frequency, choosen after many consideration
[x, x_fs] = audioread('fena_0123.wav'); % load mono signal
x = resample(x, fs, x_fs); % resampling signal

az = 90; % determine azimuth angle
load ('QU_KEMAR_anechoic_05m.mat'); % load HRIR database

% load HRIR for a determined angle
leftIR = irs.left(:,az);
rightIR = irs.right(:,az);
leftIR = resample(leftIR, fs, irs.fs);
rightIR = resample(rightIR, fs, irs.fs);

% spatialize signal
xl = conv(x, leftIR);
xr = conv(x, rightIR);

% create binaural signal
bi = [xl(:), xr(:)];

% save it in wav format
filename = 'clean_90.wav';
audiowrite(filename, bi, fs);

% we can evaluate the created audio using various metrics,
% here I used ITD and ILD for normal hearing audio

% add path to ITD extraction tools, adjust it to your folder
addpath('E:\TUGAS AKHIR\SC\PART-1\Tools_itd\'); 
% calculate ITD, right towards left
ITD = estimate_ITD_Broadband(bi, fs);

% calculate ILD, right towards left
ILD = snr(xr, xl);