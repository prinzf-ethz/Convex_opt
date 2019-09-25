clear all
close all
clc

%% Sets up the Battery configuration
car_name= 'fsg_car';            %name the car
%% Car
% constants
Par.densityAir = 1.2;           % kg/m^3
Par.constantGravity = 9.81;     % m/s^2

% masses
mass.car=180;                   % kg
mass.driver=70;                 % kg

%resistances
res.c_r= 0.04;                  % - 
res.c_d=1.32;                   % -
res.Af=1.12;                    %[m2]  --> function of slip, v and downforce

%% Actions
mass.tot= mass.car+mass.driver;
save(['C:\Users\friep\polybox\Shared\ST Prinz Friedrich\Convex_opt\Prinz\Car\' car_name])
