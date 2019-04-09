clear classes
close all
more off

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  The standard NLMS algorithms
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
adforder = 20;
nlms = NLMS(adforder+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Preparing Unknown systems
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
c0 = remez(adforder, [0 0.2 0.8 1.0], [1 1 0 0 ]);
f = SystemBaseLinear(c0);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%  Simulation Main
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
algorithms = {'algo', nlms};

s = ADFsimulation(algorithms);
s.setUnknown(f);
s.simulation();
