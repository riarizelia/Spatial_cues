% Create txt file consist of audio filenames that will be processed further
% azimuth angle in full circle with 5 degree spacing
clear all; close all; clc;

% customize this along with configuration below
fid = fopen('E:\TUGAS AKHIR\SC\PART-2\clean\bi_clean.txt', 'w');

% filename configurations
dir = 'E:\TUGAS AKHIR\SC\PART-2\clean\'; % where you wannna save the audio
ear = 'bi_'; % option: left, right, bi

% create list of audio filenames 
for  i = 5:5:360
       if i<10
           filename = strcat(dir, ear, '00', num2str(i), '_az_clean.wav');
       elseif i<100
           filename = strcat(dir, ear, '0', num2str(i), '_az_clean.wav');
       else
           filename = strcat(dir, ear, num2str(i), '_az_clean.wav');
       end
       fprintf(fid, '%s\r\n', filename);
end
fclose(fid);