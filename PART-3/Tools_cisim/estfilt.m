function estfilt(nChannels,type)


global filterA filterB center bl al
global Srate filtroA filtroB bls blo als alo nOrd2
global weight1

SAVE=0;  % if 1, save center frequencies and bandwidths in a file

% ------------------Create the filters ------------------------------
%
      if strcmp(type,'loizou') % ============== Loizou ==============

	FS=Srate/2;     %S Srate=sampling rate

	nOrd=6;         % nOrd =
	UpperFreq=5500; LowFreq=300;
	range=log10(UpperFreq/LowFreq);
	interval=range/nChannels;

	center=zeros(1,nChannels);

	for i=1:nChannels  % ----- Figure out the center frequencies for all channels
		upper1(i)=LowFreq*10^(interval*i);
		lower1(i)=LowFreq*10^(interval*(i-1));
		center(i)=0.5*(upper1(i)+lower1(i));
	end

weight1=(upper1-lower1);

if SAVE==1
fps=fopen('filters.txt','a+');
fprintf(fps,'%d channels:\n',nChannels);
for i=1:nChannels
 fprintf(fps,'%d ',round(upper1(i)-lower1(i)));
end;
fprintf(fps,'\n');
for i=1:nChannels
 fprintf(fps,'%d ',round(center(i)));
end; 
fprintf(fps,'\n=======\n');
fclose(fps);
end

	if FS<upper1(nChannels), useHigh=1;
	else			 useHigh=0;
	end

	filterA=zeros(nChannels,nOrd+1); 
	filterB=zeros(nChannels,nOrd+1); 

	 for i=1:nChannels
		W1=[lower1(i)/FS, upper1(i)/FS];
		if i==nChannels
	  	if useHigh==0
	     	  [b,a]=butter(3,W1);
	  	else
	         [b,a]=butter(6,W1(1),'high');
	  	end
	    else
	   	[b,a]=butter(3,W1);
	    end
	    filterB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	    filterA(i,1:nOrd+1)=a;   %----->  Save the coefficients 'a'
        end

% ====================================================================
elseif strcmp(type,'shannon') % ============== Shannon ==============


 srat2=Srate/2;
 rp=1.5;          % Passband ripple in dB
 rs=20;  


%----Preemphasis filter and Low-pass envelop filter -------------

	[bls,als]=ellip(1,rp,rs,1150/srat2,'high');
	[blo,alo]=butter(2,160/srat2);
 

 
rs=15.0;
nOrd=2;		% Order of filter = 2*nOrd
nOrd2=2*nOrd+1; % number of coefficients
nchan=nChannels;

if nchan==2
	
		filt2b=zeros(nchan,nOrd2);
		filt2a=zeros(nchan,nOrd2);
		[b,a]=ellip(nOrd,rp,rs,[50/srat2 1500/srat2]);
		filt2b(1,:)=b; filt2a(1,:)=a;
		[b,a]=ellip(nOrd,rp,rs,[1500/srat2 4000/srat2]);
		filt2b(2,:)=b; filt2a(2,:)=a;
	
	filtroA=zeros(nchan,nOrd2); filtroB=zeros(nchan,nOrd2);
	filtroA=filt2a; filtroB=filt2b;
elseif nchan==3
	
		filt3b=zeros(nchan,2*nOrd+1);
		filt3a=zeros(nchan,2*nOrd+1);
		crsf=[50 800 1500 4000];
		for i=1:3
		  lf=crsf(i)/srat2; ef=crsf(i+1)/srat2;
		  [b,a]=ellip(nOrd,rp,rs,[lf ef]);
		  filt3b(i,:)=b; filt3a(i,:)=a;
		end
	
	filtroA=zeros(nchan,2*nOrd+1); filtroB=zeros(nchan,2*nOrd+1);
	filtroA=filt3a; filtroB=filt3b;	  
elseif nchan==4
	
		filt4b=zeros(nchan,2*nOrd+1);
		filt4a=zeros(nchan,2*nOrd+1);
		crsf4=[50 800 1500 2500 4000];
		for i=1:4
		  lf=crsf4(i)/srat2; ef=crsf4(i+1)/srat2;
		  [b,a]=ellip(nOrd,rp,rs,[lf ef]);
		  filt4b(i,:)=b; filt4a(i,:)=a;
		end
		
		
	filtroA=zeros(nchan,2*nOrd+1); filtroB=zeros(nchan,2*nOrd+1);
	filtroA=filt4a; filtroB=filt4b;
	
  end

% ====================================================================
elseif strcmp(type,'mel')  % ============= use Mel spacing ==========

	FS=Srate/2;
	nOrd=6;
	[lower1,center,upper1]=mel(nChannels,50,5500);

%lower1=[256,550, 774,1036,1342,1699,2116,2801]; %condition B
%upper1=[550,774,1036,1342,1699,2116,2801,5008];

%lower1=[356,549, 1036,1342,1699,2115,2605,3829]; % condition C
%upper1=[549,1036,1342,1699,2115,2605,3829,4600];


%lower1=[356,549, 1036,1342,1699,2115,2605,3168]; % condition D
%upper1=[549,1036,1342,1699,2115,2605,3168,4600];

%lower1=[549, 1036,1342,1699,2115,2605,3168,3829]; % condition E
%upper1=[1036,1342,1699,2115,2605,3168,3829,4600];


center=0.5*(lower1+upper1);

weight1=(upper1-lower1);

if SAVE==1
fps=fopen('filters.txt','a+');
fprintf(fps,'%d channels:\n',nChannels);
for i=1:nChannels
 fprintf(fps,'%d ',round(upper1(i)-lower1(i)));
end;
fprintf(fps,'\n');
for i=1:nChannels
 fprintf(fps,'%d ',round(center(i)));
end; 
fprintf(fps,'\n=======\n');
fclose(fps);
end

	if FS<upper1(nChannels), useHigh=1;
	else			 useHigh=0;
	end

	filterA=zeros(nChannels,nOrd+1); 
	filterB=zeros(nChannels,nOrd+1); 

	PLT=0;
	 for i=1:nChannels
		W1=[lower1(i)/FS, upper1(i)/FS];
		if i==nChannels
	  	if useHigh==0
	     	  [b,a]=butter(nOrd/2,W1);
	  	else
	         [b,a]=butter(nOrd,W1(1),'high');
	  	end
	    else
	   	[b,a]=butter(nOrd/2,W1);
	    end
	    filterB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	    filterA(i,1:nOrd+1)=a;   %----->  Save the coefficients 'a'

	     if PLT==1, [h,f]=freqz(b,a,512,Srate);
		     plot(f,20*log10(abs(h)));
		     axis([0 6000 -50 5]);
		     hold on;
	      end;

				
         end
	if PLT==1, pause; end;

%=============================== SPEAK filters ==============
elseif strcmp(type,'SPEAK')

if nChannels~=20 | Srate<20000 %20
  error('Error in estfilt.m. Nchannels should be = 20 or sampling freq < 20000 Hz');
end;

fprintf('\nEstimating SPEAK type filters..\n');

upper1=zeros(1,20); %20 --- 22
lower1=zeros(1,20);
cen=zeros(1,20);

	low(1)=150;  
	for i=2:9
	  low(i)=low(i-1)+200;
	end
	up(1:8)=low(2:9);   % Linear spacing up to 1650 Hz, in steps of 200 Hz

DBG=0;
upper1(1:8)=up;
lower1(1:8)=low(1:8);
cen(1:8)=0.5*(upper1(1:8)+lower1(1:8));

numch=5;
UpperFreq=3300;
LowFreq=1650;
	
range=log10(UpperFreq/LowFreq);
interval=range/numch;


k=9;
for i=1:numch  % ----- Figure out the center frequencies for all channels
	upper1(k)=LowFreq*10^(interval*i);
	lower1(k)=LowFreq*10^(interval*(i-1));
	cen(k)=0.5*(upper1(k)+lower1(k));
	k=k+1;	
end


numch=7;
UpperFreq=10000;
LowFreq=3300;
	
range=log10(UpperFreq/LowFreq);
interval=range/numch;



k=14;
for i=1:numch  % ----- Figure out the center frequencies for all channels
	upper1(k)=LowFreq*10^(interval*i);
	lower1(k)=LowFreq*10^(interval*(i-1));
	cen(k)=0.5*(upper1(k)+lower1(k));
	k=k+1;	
end

center = cen;  % center frequencies


FS=Srate/2;

numch2=20;
nOrd=6;
Rp=2;

filtA=zeros(numch2,nOrd+1); 
filtB=zeros(numch2,nOrd+1); 


 for i=1:numch2
	W1=[lower1(i)/FS, upper1(i)/FS];
	
	if i<=5
	[b,a]=cheby1(nOrd/2,Rp,W1);
	else
	 [b,a]=butter(nOrd/2,W1);
	end

	filterB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	filterA(i,1:nOrd+1)=a;   %-----> Save the coefficients 'a'

	
	if  DBG==1
	 [h,f]=freqz(b,a,512,Srate);
	 semilogx(f,10*log10(abs(h)),'m');
	 axis([100 FS -50 5]);
	 hold on
	 ylabel('Amplitude (dB)');
	 xlabel('Frequency (Hz)');
	 grid on
	end
  end
center = cen;  % center frequencies


FS=Srate/2;

numch2=22;
nOrd=6;
Rp=2;

filtA=zeros(numch2,nOrd+1); 
filtB=zeros(numch2,nOrd+1); 


 for i=1:numch2
	W1=[lower1(i)/FS, upper1(i)/FS];
	
	if i<=5
	[b,a]=cheby1(nOrd/2,Rp,W1);
	else
	 [b,a]=butter(nOrd/2,W1);
	end

	filterB(i,1:nOrd+1)=b;   %----->  Save the coefficients 'b'
	filterA(i,1:nOrd+1)=a;   %-----> Save the coefficients 'a'

	
	if  DBG==1
	 [h,f]=freqz(b,a,512,Srate);
	 semilogx(f,10*log10(abs(h)),'m');
	 axis([100 FS -50 5]);
	 hold on
	 ylabel('Amplitude (dB)');
	 xlabel('Frequency (Hz)');
	 grid on
	end
  end

end
% ----------------------
