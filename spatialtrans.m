function  [e_kin_max]= spatialtrans(fsg,snom)


%start point
fsg.s.v(1)=0;     
fsg.s.p(1)=0;  
fsg.s.e(1)=0;
% from velocity
for i=2:length(fsg.sampled10.time)
     fsg.s.v(i)=fsg.s.v(i-1)+fsg.sampled10.v_tot(i-1)*fsg.sampled10.time(2);
end 

%from points
for i=2:length(fsg.sampled10.time)
        fsg.s.p(i)=fsg.s.p(i-1)+(sqrt((fsg.sampled10.x_pos(i)-fsg.sampled10.x_pos(i-1))^2+...
        (fsg.sampled10.y_pos(i)-fsg.sampled10.y_pos(i-1))^2));
end

%error
for i=2:length(fsg.sampled10.time)-1
    fsg.s.e(i)=fsg.s.p(i)-fsg.s.v(i);
end


% figure
% subplot(3,1,1)
%     plot(fsg.s.e)
%     title('error')
%     hold on
%     xlabel('samples [-]')
%     ylabel('distance [m]')
% subplot(3,1,2)
%      plot(fsg.s.p)
%      title('Position GPS')
%      hold on      
%     xlabel('samples [-]')
%     ylabel('distance [m]')
% subplot(3,1,3)
%     plot(fsg.s.v)
%     title('Position Velocity')
%     xlabel('samples [-]')
%     ylabel('distance [m]')


%from the result it is clear, the velocity data shall be used for distance evalution
%1356.2m in 76 sec --> one round
d_int=0:snom:1356.2;
xt=0:0.05:1519*0.05;
t_int=spline(fsg.s.v(0.2e4:0.2e4+1519)-fsg.s.v(0.2e4),xt,d_int);

% figure 
% plot(t_int,d_int)
% title('position')
% ylabel('distance[m]')
% xlabel('time [s]')

e_kin_max=spline(xt,fsg.e_kin_max,t_int);
% figure
% plot(d_int,e_kin_max)
% title('ekin')
% ylabel('energie[J]')
% xlabel('distance [m]')

e_kin_max=e_kin_max';
end