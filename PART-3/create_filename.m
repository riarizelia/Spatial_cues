% Create txt file consist of audio filenames that will be processed further
% FOR BI-VOCODED STIMULI
clear all; close all; clc;

% customize this along with configuration below
fid = fopen('E:\TUGAS AKHIR\SC\PART-3\cis\6_channel\right_cis_6.txt', 'w');

% filename configurations
dir = 'E:\TUGAS AKHIR\SC\PART-3\cis\6_channel\';
ear = 'right_'; % option: left, right, bi
voc = 'cis_'; % option: cis, speak
chan = '6'; % option: 2 to 22 channels

% create list of audio filenames 
for  i = 5:5:360
       if i<10
           filename = strcat(dir, ear, '00', num2str(i), '_az_clean_', voc, chan, '.wav');
       elseif i<100
           filename = strcat(dir, ear, '0', num2str(i), '_az_clean_', voc, chan, '.wav');
       else
           filename = strcat(dir, ear, num2str(i), '_az_clean_', voc, chan, '.wav');
       end
       fprintf(fid, '%s\r\n', filename);
end
fclose(fid);