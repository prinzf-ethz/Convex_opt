function  [fsg]= trackdata(w)
load('GO 2016-08-14 16-47-40 02_Endu_1_man.mat')
%% Raw data collection
%time
fsg.raw.time=sens.Time;
%position
fsg.raw.x_pos=sens.x_pos;
fsg.raw.y_pos=sens.y_pos;
%Voltage and Current
fsg.raw.shunt_i_current=sens.shunt_i_current;
fsg.raw.shunt_u_voltage=sens.shunt_u_voltage;
%velocity
fsg.raw.v_x_Kal=sens.v_x_Kal;
fsg.raw.v_y=sens.v_y;
%acceleration
fsg.raw.a_x=sens.a_x;
fsg.raw.a_y=sens.a_y;
%gas throttle
fsg.raw.throttle=sens.throttle_1;
%shunt
fsg.raw.shunt_P=sens.shunt_i_current.*sens.shunt_u_voltage;

%% downsample

fsg.sampled10.time=downsample(fsg.raw.time,10);
fsg.sampled10.x_pos=downsample(fsg.raw.x_pos,10);
fsg.sampled10.y_pos=downsample(fsg.raw.y_pos,10);
fsg.sampled10.v_x_Kal=downsample(fsg.raw.v_x_Kal,10);
fsg.sampled10.v_y=downsample(fsg.raw.v_y,10);
fsg.sampled10.a_x=downsample(fsg.raw.a_x,10);
fsg.sampled10.a_y=downsample(fsg.raw.a_y,10);
fsg.sampled10.throttle=downsample(fsg.raw.throttle,10);
fsg.sampled10.shunt_P=downsample(fsg.raw.shunt_P,10);

%% calculate 
%total speed
fsg.sampled10.v_tot=sqrt(fsg.sampled10.v_x_Kal.^2+fsg.sampled10.v_y.^2);
%wheel forces
fsg.sampled10.F_tot=sqrt(fsg.sampled10.a_x.^2+fsg.sampled10.a_y.^2)*(w);
%normalize throttle
fsg.sampled10.throttle=(fsg.sampled10.throttle-28)/161;
%total acceleration
fsg.sampled10.a_tot=sqrt(fsg.sampled10.a_x.^2+fsg.sampled10.a_y.^2);



%% maximum kinetic energy profile
n=0;

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
fsg.v_max= fsg.sampled10.v_tot(find(fsg.e_kin_max==max(fsg.e_kin_max)));
fsg.a_max=max(fsg.sampled10.a_tot);

fsg.e_kin_Inital=sqrt(fsg.raw.v_x_Kal(0.2e4)^2+fsg.raw.v_y(0.2e4)^2)*1/2*w;
fsg.e_kin_Final=sqrt(fsg.raw.v_x_Kal(0.2e4+1520)^2+fsg.raw.v_y(0.2e4+1520)^2*1/2*w);


clear sens i n  r v_tot_temp weight_driver weight_gotthard w car
end
