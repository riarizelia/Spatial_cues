% Create clean spatialized signal for Normal Hearing (NH)
clear all; close all; clc;

fs = 16000;
addpath('E:\TUGAS AKHIR\SC\PART-2\Tools_itd\'); % add path to ITD extraction tools
load ('QU_KEMAR_anechoic_05m.mat'); % load HRIR database

% load txt file consist of audio filenames
fid_angle = fopen('E:\TUGAS AKHIR\SC\PART-2\angle.txt', 'r');
fid_leftClean = fopen('E:\TUGAS AKHIR\SC\PART-2\clean\left_clean.txt', 'r');
fid_rightClean = fopen('E:\TUGAS AKHIR\SC\PART-2\clean\right_clean.txt', 'r');
fid_biClean = fopen('E:\TUGAS AKHIR\SC\PART-2\clean\bi_clean.txt', 'r');

% load audio input
[x, x_fs] = audioread('fena_0123.wav');
x = resample(x, fs, x_fs);

% measure spatial cues
itd_all = [];
ild_all = [];

while ~feof(fid_angle)
    % load HRIR for a certain angle
    az = fgetl(fid_angle);
    az = str2num(az)

    leftIR = irs.left(:,az);
    rightIR = irs.right(:,az);
    leftIR = resample(leftIR, fs, irs.fs);
    rightIR = resample(rightIR, fs, irs.fs);
    
    % spatialize audio
    xl = conv(x, leftIR);
    xr = conv(x, rightIR);
    
    % create binaural audio
    bi = [xl(:), xr(:)];
    
    % calculate ITD, right towards left
    ITD = estimate_ITD_Broadband(bi, fs);
    itd_all = [itd_all, ITD];

    % calculate ILD, right towards left
    ILD = snr(xr, xl);
    ild_all = [ild_all, ILD];

    % read filename
    filename_left = fgetl(fid_leftClean);
    filename_right = fgetl(fid_rightClean);
    filename_bi = fgetl(fid_biClean);

    % save audio output
    audiowrite(filename_left, xl, fs);
    audiowrite(filename_right, xr, fs);
    audiowrite(filename_bi, bi, fs);
end 

% store the measured cues, the number in first row is for 5 degree, second
% row is for 10 degree, etc. it follows the order in angle.txt
itd_all = itd_all';
ild_all = ild_all';