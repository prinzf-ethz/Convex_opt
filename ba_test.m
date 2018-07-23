clear all
close all
clc
tic

%% Add convex parser, solvers and packs
addpath(genpath('C:\Users\friep\polybox\Shared\ST Prinz Friedrich\Convex_opt\Prinz'));

%% load data
CarData=load('fsg_car');
TrackData =  trackdata(CarData.mass.tot);
snom=10;                       %spatial partition [m]
[TrackData.e_kin_max_s] =spatialtrans(TrackData, snom);
nSteps=length(TrackData.e_kin_max_s);

SOCvar=1e1;         %only multipls of 10

%% Energy
e_kin = sdpvar(nSteps,1);
enom = 0.5 * CarData.mass.tot * TrackData.v_max^2;
e_init = TrackData.e_kin_max_s(1)/enom;
e_end = TrackData.e_kin_max_s(end)/enom;

%% Forces
F_roll=CarData.res.c_r*CarData.mass.tot*CarData.Par.constantGravity;
F_air_factor=CarData.res.c_d*CarData.res.Af*CarData.Par.densityAir/CarData.mass.tot;

f = sdpvar(nSteps,1);


%% Speed
v = sdpvar(nSteps,1);
vnom = TrackData.v_max;
fnom = 80000/vnom;
%% Time
t = sdpvar(nSteps,1);
tnom = 0.75;


%% normalized capacity force
fi = sdpvar(nSteps,1);
finom = fnom;

%% normalized SOC diff
diffEb = sdpvar(nSteps,1);              %SOC
Ebnom=9846144/12;%[J]


%% alpha efficiency of power train
a = sdpvar(nSteps,1);

%% batteries
ba = sdpvar(1);

%%weight
w = sdpvar(1);
wnor= CarData.mass.tot-28.476;

constraint = [w*wnor>=wnor+ba*0.126];

constraints = [constraint; ba>=1]; 



%cost function:
costfcn = w+ba;

options = sdpsettings('solver','ecos'); %ecos, sedumi 
options.ecos.maxit = 100; 

out = solvesdp(constraint,costfcn,options);