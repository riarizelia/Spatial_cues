% Create vocoded-spatialized signal for Bilateral Cochlear Implant (BiCI)
clear all; close all; clc;

fs = 16000;
addpath('E:\TUGAS AKHIR\SC\PART-3\Tools_cisim\'); % add path to cis simulation tools
addpath('E:\TUGAS AKHIR\SC\PART-3\Tools_itd\'); % add path to ITD extraction tools

% load txt file consist of clean audio filenames
fid_leftClean = fopen('E:\TUGAS AKHIR\SC\PART-2\clean\left_clean.txt', 'r');
fid_rightClean = fopen('E:\TUGAS AKHIR\SC\PART-2\clean\right_clean.txt', 'r');

% load txt file consist of vocoded audio filenames
fid_leftCisim = fopen('E:\TUGAS AKHIR\SC\PART-3\cis\6_channel\left_cis_6.txt', 'r');
fid_rightCisim = fopen('E:\TUGAS AKHIR\SC\PART-3\cis\6_channel\right_cis_6.txt', 'r');
fid_biCisim = fopen('E:\TUGAS AKHIR\SC\PART-3\cis\6_channel\bi_cis_6.txt', 'r');

% vocoder configurations, for cis vocoder: n channel = m channel
% for speak vocoder: n channel = 22, customize m accordingly
n_chan = 6;
m_chan = 6; 

% measure spatial cues
itd_all = [];
ild_all = [];
mbstoi_all = [];

% count the iteration
iterCount = 0;

while ~feof(fid_leftClean)
    % load clean signal
    file_leftClean = fgetl(fid_leftClean);
    file_rightClean = fgetl(fid_rightClean);
    [xl, xl_fs] = audioread(file_leftClean);    
    [xr, xr_fs] = audioread(file_rightClean);
    
    % create vocoded signal
    file_leftCisim = fgetl(fid_leftCisim);
    cisim(n_chan, file_leftClean, file_leftCisim, m_chan);

    file_rightCisim = fgetl(fid_rightCisim);
    cisim(n_chan, file_rightClean, file_rightCisim, m_chan);

    % load vocoded signal
    [yl, yl_fs] = audioread(file_leftCisim);
    [yr, yr_fs] = audioread(file_rightCisim);

    % create bilateral vocoded signal
    yb = [yl(:), yr(:)];
    file_biCisim = fgetl(fid_biCisim);
    audiowrite(file_biCisim, yb, fs);

    % calculate ITD, right towards left
    ITD = estimate_ITD_Broadband(yb, fs);
    itd_all = [itd_all, ITD];

    % calculate ILD, right towards left
    ILD = snr(yr, yl);
    ild_all = [ild_all, ILD];
   
    % calculate mbstoi
    MBSTOI = mbstoi(xl, xr, yl, yr, fs);
    mbstoi_all = [mbstoi_all, MBSTOI];
    
    % count the iteration
    iterCount = iterCount +5
end

itd_all = itd_all';
ild_all = ild_all';
mbstoi_all = mbstoi_all';