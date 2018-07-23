clear all
close all
clc

%% Add convex parser, solvers and packs 
addpath(genpath('C:\Users\friep\polybox\Shared\ST Prinz Friedrich\Convex_opt\Prinz'));

%% load data
CarData=load('fsg_car');
TrackData =  trackdata(CarData.mass.tot);

%% get f_f
index=1;
for i=2e4:(2e4+15200)
    if (CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i)))>= 0.1
    
        f_f(1,index)=(CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i)));
    
    f_f(2,index)=i;
    index=index+1;
    elseif (CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i)))<= -0.1
    
        f_f(1,index)=(CarData.mass.tot*(TrackData.raw.a_x(i)+TrackData.raw.a_y(i)));
     
    f_f(2,index)=i;
    index=index+1;
    end
end
%filter P_f --> filter 0 values and percentile 
 f_f_max = prctile(f_f(1,:),95);
 f_f_min = prctile(f_f(1,:),5);
 index=1;
 for i=1:length(f_f)
     if f_f(1,i)>= f_f_min && f_f(1,i)<= f_f_max;
         f_f_final(1,index)= f_f(1,i);   
         f_f_final(2,index)= f_f(2,i); 
         index=index+1; 
     end
 end
 
 %% get f_i
 n=1;
 for i=1:length(f_f)
     if f_f(1,i)>= f_f_min && f_f(1,i)<= f_f_max;
         index= f_f(2,i);
           f_i(n)= (TrackData.raw.shunt_i_current(index)*...
               TrackData.raw.shunt_u_voltage(index)+...
               TrackData.raw.shunt_i_current(index).*113e-3)/(sqrt(TrackData.raw.v_x_Kal(index)^2+TrackData.raw.v_y(index)^2));
           n=n+1;
     end
 end
 figure
 plot(f_i(1,:),f_f_final(1,:))
 hold on 

fun = @(a,xdata) a*xdata.^2+xdata;
xdata=f_f_final(1,:);
ydata=f_i;
x0=6.5527e-05; 
x = lsqcurvefit(fun,x0,xdata,ydata)
fplot( @(x) (6.5527e-05)*x.^2+x)
xlabel('vehicle force')
ylabel('accu internal force')
