clear all
close all
clc

%% Add convex parser, solvers and packs 
addpath(genpath('C:\Users\friep\polybox\Shared\ST Prinz Friedrich\Convex_opt\Prinz'));

%% load data
CarData=load('fsg_car');
TrackData =  trackdata(CarData.mass.tot);

%% get P_f
index=1;
for i=2e4:(2e4+15200)
    if (CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i))...
        *sqrt(TrackData.raw.v_x_Kal(i)^2+TrackData.raw.v_y(i)^2))>= 0.1
        P_f(1,index)=CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i))...
        *sqrt(TrackData.raw.v_x_Kal(i)^2+TrackData.raw.v_y(i)^2);
    
    P_f(2,index)=i;
    index=index+1;
    elseif (CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i))...
        *sqrt(TrackData.raw.v_x_Kal(i)^2+TrackData.raw.v_y(i)^2))<= -0.1
        P_f(1,index)=CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i))...
        *sqrt(TrackData.raw.v_x_Kal(i)^2+TrackData.raw.v_y(i)^2);
     
    P_f(2,index)=i;
    index=index+1;
    end
end
%filter P_f --> filter 0 values and percentile 
 P_f_max = prctile(P_f(1,:),95);
 P_f_min = prctile(P_f(1,:),5);
 index=1;
 for i=1:length(P_f)
     if P_f(1,i)>= P_f_min && P_f(1,i)<= P_f_max;
         P_f_final(1,index)= P_f(1,i);   
         P_f_final(2,index)= P_f(2,i); 
         index=index+1; 
     end
 end
 
 %% get P_i
 n=1;
 for i=1:length(P_f)
     if P_f(1,i)>= P_f_min && P_f(1,i)<= P_f_max;
         index= P_f(2,i);
           P_i(n)= (TrackData.raw.shunt_i_current(index)*...
               TrackData.raw.shunt_u_voltage(index)+...
               TrackData.raw.shunt_i_current(index).*113e-3);
           n=n+1;
     end
 end
 figure
 plot(P_i(1,:),P_f_final(1,:))
 hold on 
%  figure
%  plot(P_i)
%  figure
%  plot(P_f_final(1,:))
%  
fun = @(a,xdata) a*xdata.^2+xdata;
xdata=P_f_final(1,:);
ydata=P_i;
x0=0.1; 
x = lsqcurvefit(fun,x0,xdata,ydata)
fplot( @(x) 4.1354e-06*x.^2+x)
xlabel('vehicle Power')
ylabel('accu internal Power')
