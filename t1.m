clear classes
close all
more off

%%%%%%%%%%%%%%%%%%%%%%%%%%
nmax = 2000;                % max n
naverage= 10;               % the number of ensemble averaging
systemchangetime = 1000;     % time when unknown system change
SNR = 30;                   % SNR (dB) of AWGN
inputarcoef = 0.95;         % value of the AR(1) coef of the input signal
impulseProb = 0.005;        % Probability of the impulse noise.
impulseAmp = 1.0;           % Amplitude of the impulse noise.
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   Unknown system
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
forder = 20;
r0 = remez(forder, [0 0.2 0.8 1.0], [1 1 0 0 ]);
r1 = remez(forder, [0 0.5 0.8 1.0], [0 0 1 1 ]);

[s1 s2] = size(r0);
if s1 > s2
    r0 = r0';
    r1 = r1';
end
c0 = r0;
c1 = r1;
adforder = length(c0) -1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   Global variables used in the NLMS and the proposed
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gstepsize = 0.7;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   NLMS algorithm
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nlms = NLMS(adforder+1);
nlms.setStepsize(gstepsize);
bname = sprintf('NLMS(a = %.2f)', gstepsize);
nlms.setName(bname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   Proposed method
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
forgetSM = 1.0;
forgetSD = 0.5;
bandwidth = 10.0;

gsnlms1 = GSNLMS(adforder+1, nmax, forgetSM, forgetSD, bandwidth);
bname = sprintf('Proposed 1');
gsnlms1.setName(bname);
gsnlms1.setStepsize(gstepsize);

%%%
forgetSM = 0.3;
forgetSD = 0.5;
bandwidth = 10.0;

gsnlms2 = GSNLMS(adforder+1, nmax, forgetSM, forgetSD, bandwidth);
bname = sprintf('Proposed 2');
gsnlms2.setName(bname);
gsnlms2.setStepsize(gstepsize);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%   Simulation main
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = SystemImpulseNoise(c0, c1);
f.setNchange(systemchangetime);
f.setSNR(SNR);
f.setARcoef(inputarcoef);
f.setImpulseAmp(impulseAmp);
f.setImpulseProb(impulseProb);

algorithms = {'algo', nlms, gsnlms1, gsnlms2};
dlen = {'dlen', naverage, nmax};

s = ADFsimulation(dlen, algorithms);
s.setUnknown(f);
s.setLegendPosition('northeast');
s.simulation();

fbase= 'y-fig-tk2-nlms-v0.7-0.4';
msdfname = sprintf('%s-msd1.eps', fbase);
msefname = sprintf('%s-mse1.eps', fbase);
