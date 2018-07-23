clear all
close all
clc

load('fsg_track')
w=(weight_driver+weight_gotthard);
n=0;
%% maximum kinetic energy profile
for i=1:1520
    if fsg.sampled10.throttle(0.2e4+i) <= 0.75
        fsg.e_kin_max(i)=1/2*(w)*fsg.sampled10.v_tot(0.2e4+i)^2;
        n=0;
    else
        n=n+1;
        v_tot_temp=fsg.sampled10.v_tot(0.2e4+i-n);
        for r=1:n
        v_tot_temp=v_tot_temp+(80000/(w*v_tot_temp))*fsg.sampled10.time(2);
        end 
        fsg.e_kin_max(i)=1/2*(w)*v_tot_temp^2;
        
    end
    
end