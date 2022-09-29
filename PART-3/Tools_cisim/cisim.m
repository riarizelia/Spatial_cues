function [dt1,dt2,dt3,dt4,dt5,dt6,dt7,dt8,dt9,dt10,dt11,dt12,dt13,dt14,dt15,dt16,dt17,dt18,dt19,dt20,dt21,dt22]=cisim(nch,filename,outfile,mn)

% Usage: cisim (NChannels,InputFileName,OutputFile,MchannelsSelected)
%        Nchannels -- total number of channels
%        Inputfilename - Input filename
%        OutputFile  - Output filename (needs to have a .wav extension)
%        MChannelsSelected   - number of channels stimulated out of nch channels. 
%                   The mn maximum channel amplitudes are selected in each cycle.
%                   
%  To implement a CIS processor, set Nchannels=MchannelsSelected
%  To implement a m-of-n (SPEAK-type) processor, MchannelsSelected < Nchannels
%
% Copyright (c) 1995-2001 Philipos C. Loizou
%

global filterA filterB bl al  center Srate
global  ftype bpsa 

if mn>nch || mn<=0
  fprintf('\n\nERROR: m=%d should be smaller than %d\n',mn,nch);
  error('ERROR');
 return;
end

LPF=0;
LPF_act=0;

%weights=[1,1,0,0,1,1];

fpin=fopen(filename,'r');
if fpin<=0
  fprintf('\nERROR! Could not open input file: %s\n',filename);
  return;
end

ind1=find(filename == '.');
if length(ind1)>1, ind=ind1(length(ind1)); else, ind=ind1; end
ext = lower(filename(ind+1:length(filename))); 

[~,Srate,bpsa, ftype] =  gethdr(fpin,ext);


x=fread(fpin,inf,ftype);
n_samples=length(x);


duration=4; % in msec
fRate=round(duration*Srate/1000);

FFTlen=fRate;
nChannels=nch;
rsln=Srate/FFTlen;



meen=mean(x);
x= x - meen; %----------remove any DC bias---

%---------------------estimate the filters ----------------
%
 
 if isempty(filterA) 
	%if nChannels<8, estfilt(nChannels,'loizou');
    if nChannels>=8 && nChannels<=22
	  estfilt(nChannels,'mel');
	elseif nChannels==22
	  estfilt(nChannels,'mel');
    else
      estfilt(nChannels,'mel');
    end
	fprintf('\n Implementing a %d-of-%d processor..\n',mn,nch)
 end

k=1; 

nFrames=floor(n_samples/fRate);


 if isempty(bl)
    [bl,al]=butter(2,400/(Srate/2));
 end

%--Preemphasize first---------
bp = exp(-1200*2*pi/Srate);
ap = exp(-3000*2*pi/Srate);

 %plot impulse 
x = filter([1 -bp],[1 -ap],x); 
y=zeros(nChannels,n_samples);
h = []; w = [];
for i=1:nChannels
	% y1=filter(filterB(i,:),filterA(i,:), x)';
	y1=filter(filterB(i,:),filterA(i,:), x)';
    y(i,:)=filter(bl,al,abs(y1));
     [h(i,:),w(i,:)] = freqz(filterB(i,:),filterA(i,:),2001);
end

dt1=[w(1,:)/pi;20*log10(abs(h(1,:)))];
dt2=[w(2,:)/pi;20*log10(abs(h(2,:)))];
dt3=[w(3,:)/pi;20*log10(abs(h(3,:)))];
dt4=[w(4,:)/pi;20*log10(abs(h(4,:)))];
dt5=[w(5,:)/pi;20*log10(abs(h(5,:)))];
dt6=[w(6,:)/pi;20*log10(abs(h(6,:)))];
% dt7=[w(7,:)/pi;20*log10(abs(h(7,:)))];
% dt8=[w(8,:)/pi;20*log10(abs(h(8,:)))];
% dt9=[w(9,:)/pi;20*log10(abs(h(9,:)))];
% dt10=[w(10,:)/pi;20*log10(abs(h(10,:)))];
% dt11=[w(11,:)/pi;20*log10(abs(h(11,:)))];
% dt12=[w(12,:)/pi;20*log10(abs(h(12,:)))];
% dt13=[w(13,:)/pi;20*log10(abs(h(13,:)))];
% dt14=[w(14,:)/pi;20*log10(abs(h(14,:)))];
% dt15=[w(15,:)/pi;20*log10(abs(h(15,:)))];
% dt16=[w(16,:)/pi;20*log10(abs(h(16,:)))];
% dt17=[w(17,:)/pi;20*log10(abs(h(17,:)))];
% dt18=[w(18,:)/pi;20*log10(abs(h(18,:)))];
% dt19=[w(19,:)/pi;20*log10(abs(h(19,:)))];
% dt20=[w(20,:)/pi;20*log10(abs(h(20,:)))];
% dt21=[w(21,:)/pi;20*log10(abs(h(21,:)))];
% dt22=[w(22,:)/pi;20*log10(abs(h(22,:)))];

% figure;
plot(w(1,:)/pi,20*log10(abs(h(1,:))),w(2,:)/pi,20*log10(abs(h(2,:))),...
    w(3,:)/pi,20*log10(abs(h(3,:))),w(4,:)/pi,20*log10(abs(h(4,:))),...
    w(5,:)/pi,20*log10(abs(h(5,:))),w(6,:)/pi,20*log10(abs(h(6,:))));
%     w(7,:)/pi,20*log10(abs(h(7,:))),w(8,:)/pi,20*log10(abs(h(8,:))),...
%     w(9,:)/pi,20*log10(abs(h(9,:))),w(10,:)/pi,20*log10(abs(h(10,:))),...
%     w(11,:)/pi,20*log10(abs(h(11,:))),w(12,:)/pi,20*log10(abs(h(12,:))),...
%     w(13,:)/pi,20*log10(abs(h(13,:))),w(14,:)/pi,20*log10(abs(h(14,:))),...
%     w(15,:)/pi,20*log10(abs(h(15,:))),w(16,:)/pi,20*log10(abs(h(16,:))),...
%     w(17,:)/pi,20*log10(abs(h(17,:))),w(18,:)/pi,20*log10(abs(h(18,:))),...
%     w(19,:)/pi,20*log10(abs(h(19,:))),w(20,:)/pi,20*log10(abs(h(20,:))),...
%     w(21,:)/pi,20*log10(abs(h(21,:))),w(22,:)/pi,20*log10(abs(h(22,:))));

ax = gca;
ax.YLim = [-100 20];
ax.XTick = 0:.1:2;
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude (dB)')

k=1; l=1;

ampl=zeros(1,nChannels);
amplmn=zeros(1,nChannels);
yout=zeros(1,nFrames*fRate);
ij=sqrt(-1);

% xx =centerFrequencies(w(1,:), 16000);

%_________________________________________________________
%


cnst=2*pi;
       freq=center/Srate;
	   indx3=round(center/rsln);
	   indx3=indx3+1;
Ac = 2/FFTlen;


for t=1:nFrames

   	xin=x(k:k+fRate-1); Ein=norm(xin,2);
	   seg=zeros(1,FFTlen);
    	seg(1:fRate)=xin;
    	yseg=fft(seg,FFTlen);
	   phase=atan2(imag(yseg(indx3)),real(yseg(indx3)));
	  
	ampl=zeros(1,nChannels);
	for i=1:nChannels
	   yin=y(i,k:k+fRate-1); 
	   amplmn(i)=norm(yin,2);
	end

	if mn == nch
	  ampl=amplmn; 
	else
      [~,inds]=sort(amplmn); % ---- pick the mn largest amplitudes
      	ampl(inds(nch-mn+1:nch))=amplmn(inds(nch-mn+1:nch)); 
	end
   
   
   
	ytest=zeros(1,FFTlen);
	for i=1:nChannels % ------ sum up mn sinewaves ---------
	   if ampl(i)>0
	     y2=Ac*cos(cnst*freq(i)*(0:FFTlen-1)+phase(i));
	     ytest=ytest+ampl(i)*y2;  
	   end
	end
	


	Eout=norm(ytest,2);% scale so that output has same energy as input
	yout(k:k+fRate-1)=ytest*Ein/Eout;
	
	k=k+fRate;
	
end %==============================================


if max(abs(yout))>32768, fprintf('Warning! Overflow in file %s\n',filename); end

%--- save output to a file ----

    %audiowrite(yout/32768,Srate,16,outfile);
     %yout = resample(yout,Srate,Srate*2);
     %audiowrite(yout/32768,Srate,16,outfile);
     %audiowrite(outfile,yout/32768,Srate,16);
     audiowrite(outfile,yout/32768,Srate);
     %audiowrite(outfile, y, Srate);
    fclose(fpin);

