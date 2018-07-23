clear all
close all
clc
tic

%% Add convex parser, solvers and packs
addpath(genpath('C:\Users\friep\polybox\Shared\ST Prinz Friedrich\Convex_opt\Prinz'));

stepsize=1;
%% load data
for i=1:stepsize:226          
%% load data   
CarData=load('fsg_car');

  CarData.massre.tot{i}=CarData.mass.tot-(226-i)*0.126;
    Ebnom{i}=i*3.7*6.6*3600/10; 
    
TrackData =  trackdata(CarData.massre.tot{i});
snom=10;                       %spatial partition [m]
[TrackData.e_kin_max_s] =spatialtrans(TrackData, snom);
nSteps=length(TrackData.e_kin_max_s);





%% Energy
e_kin = sdpvar(nSteps,1);
enom = 0.5 * CarData.massre.tot{i} * TrackData.v_max^2;
e_init = TrackData.e_kin_max_s(1)/enom;
e_end = TrackData.e_kin_max_s(end)/enom;

%% Forces
F_roll=CarData.res.c_r*CarData.massre.tot{i}*CarData.Par.constantGravity;
F_air_factor=CarData.res.c_d*CarData.res.Af*CarData.Par.densityAir/CarData.massre.tot{i};

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
% Ebnom=9846144;%[J]

 %% Constraints
%dynamics - normalized - curvature not used
constraint = diff(e_kin)/snom <= ((f(1:nSteps-1)*fnom)...
    - F_air_factor*e_kin(1:nSteps-1)*enom...
    - F_roll)/enom;

%kinetic energy constraints
constraint = [constraint; e_kin<=(TrackData.e_kin_max_s)/enom];
constraint = [constraint; e_kin(1)==e_init];  
constraint = [constraint; e_kin(end)== e_end];

% kinetic energy to speed relation
% relaxation; from E>= 1/2*m*v^2
constraint = [constraint;...
%     2* e_kin*enom/vnom^2 >= CarData.mass.tot*(v).^2 ];        %normal formulation 
    cone([ 2*e_kin*enom./CarData.massre.tot{i} + 1, 2*v*vnom, ...   %cone formulation
    2*e_kin*enom./CarData.massre.tot{i} - 1 ]')];


constraint = [constraint; e_kin>=0];    %cone constraints
constraint = [constraint; v>=0];


% %speed to time relation
% %relaxation; from dt/ds(s) >=1/v(s)
constraint = [constraint;...
%     (t*tnom)/snom<=1./(v*vnom)];
%    v(1:nSteps-1)*vnom.*diff(t)/snom <= ones(size(t)-1)];                
    cone([t*tnom/snom+v*vnom, 2*ones(size(t)), t*tnom/snom-v*vnom]')];        %works
%     cone([diff(t)*tnom/snom+v(1:nSteps-1)*vnom, 2*ones(size(t)-1), diff(t)*tnom/(snom)-v(1:nSteps-1)*vnom]')];

% % energy transformation in powertrain  --> need "real" fi from I2*r --> what
% a=6.5527e-05;     %f eff
a= 4.1354e-06;      %p eff

% constraint = [constraint; (diff(t)*tnom)/snom.*(fi(1:nSteps-1)*finom-f(1:nSteps-1)*fnom)>=a*f(1:nSteps-1).^2.*fnom^2];
constraint = [constraint; cone([t*tnom/snom-f*fnom+fi*finom, 2*sqrt(a)*f*fnom, ...
  t*tnom/snom+f*fnom-fi*finom]')];

% constraint = [constraint; cone([diff(t)*tnom/snom-f(1:nSteps-1)*fnom+fi(1:nSteps-1)*finom, 2*sqrt(a)*f(1:nSteps-1)*fnom, ...
%   diff(t)*tnom/snom+f(1:nSteps-1)*fnom-fi(1:nSteps-1)*finom]')]

% constraint = [constraint; f<=fi];
% constraint = [constraint; f*fnom==(0.8).^sign(fi)*fi*finom];
% constraint = [constraint; a>=6.5527e-05*snom./(t*tnom)];
% constraint = [constraint; fi*finom>=f.^2*fnom^2.*a+f*fnom];  % works 
% constraint = [constraint; cone([((fi*finom-f*fnom)/a)+1, 2*f*fnom,...
% ((fi*finom-f*fnom)/a)-1]')];  % works 


% % discharge battery
constraint = [constraint; (diff(diffEb)/snom*Ebnom{i}<=-fi(1:nSteps-1)*finom)];
% 
% %max discharge and charge battery  --> needs tuning to reality and curr. v
constraint = [constraint; fi<=0.8]; 
constraint = [constraint; fi>=-1.2];

constraint = [constraint; f<=1];    %needed due to relaxation of power constraint
constraint = [constraint; f>=-1];
% 
% SOC constraints
constraint = [constraint; diffEb(end)>=0];
constraint = [constraint; diffEb<=1];
constraint = [constraint; diffEb(1)==1];


%cost function:
costfcn = sum(t);

options = sdpsettings('solver','ecos'); %ecos, sedumi 
options.ecos.maxit = 100; 

out = solvesdp(constraint,costfcn,options);


%%  plots 
s=2;                    %row
z=3;                    %column
n=1;

clear ax

figure
ax(1) = subplot(s,z,n);
plot(double(v)*vnom);
title('velocity');
grid on
grid minor
n=n+1;

ax(2) = subplot(s,z,n);
plot(double(e_kin)*enom,'b');
title('e_kin');
hold on

plot(TrackData.e_kin_max_s,'--r');
title('max e_kin');
grid on
grid minor
n=n+1;

ax(3) = subplot(s,z,n);
plot(double(fi)*fnom,'b');
title('internal battery forces');
hold on
plot(double(f)*fnom,'--r');
title('battery forces');
grid on
grid minor
n=n+1;

ax(4) = subplot(s,z,n);
plot(double(diffEb));
title('SOC');
grid on
grid minor
n=n+1;

ax(5) = subplot(s,z,n);
plot(double(t));
title('time');
grid on
grid minor



linkaxes(ax,'x');
 
toc

%% results 

res{i}=sum(double(t)*tnom)   ;          %human driver does it in 76.1328sec and best possible is 75.5817
end

figure 
plot(1:stepsize:226,cell2mat(res))
title('time with different # of batteries');
xlabel('# batteries')
ylabel('time [s]')
grid on 
grid minor
