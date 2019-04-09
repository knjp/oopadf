clear classes
close all
more off

%%%%%%%%%%%%%%%%%%%%%%%%%%
nmax = 1000;                % max n
naverage= 20;               % the number of ensemble averaging
systemchangetime = 600;     % time when unknown system change
SNR = 20;                   % SNR
inputarcoef = 0.95          % value of the AR(1) coef
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  The standard NLMS algorithms
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
stepsize1 = 0.1;
stepsize2 = 1.0;
adforder = 20;
nlms1 = NLMS(adforder+1);
nlms1.setStepsize(stepsize1);
lname1 = sprintf('stepsize %.2f', stepsize1);
nlms1.setName(lname1);

nlms2 = NLMS(adforder+1);
nlms2.setStepsize(stepsize2);
lname2 = sprintf('stepsize %.2f', stepsize2);
nlms2.setName(lname2);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Preparing Unknown systems
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = remez(adforder, [0 0.2 0.8 1.0], [1 1 0 0 ]);
c1 = remez(adforder, [0 0.5 0.8 1.0], [0 0 1 1 ]);
f = SystemImpulseNoise(c0, c1);
f.setNchange(systemchangetime);
f.setSNR(SNR);
f.setARcoef(inputarcoef);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Simulation Main
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
algorithms = {'algo', nlms1, nlms2};
dlen = {'dlen', naverage, nmax};

s = ADFsimulation(dlen, algorithms);
s.setUnknown(f);
s.setLegendPosition('northeast');
s.simulation();
