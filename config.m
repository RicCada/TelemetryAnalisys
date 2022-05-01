%{

CONFIG - This script sets up all the parameters for the simulation
All the parameters are stored in the "settings" structure.



Copyright © 2021, Skyward Experimental Rocketry, AFD department
All rights reserved

SPDX-License-Identifier: GPL-3.0-or-later

%}

%% MISSION FILE
% Choose the mision you want to simulate from rocketsData folder
settings.mission = 'Lynx_Roccaraso_September_2021';
% settings.mission = 'Lynx_Portugal_October_2021';
% settings.mission = 'Pyxis_Roccaraso_September_2022';

%% LAUNCH SETUP
% launchpad directions
% for a single run the maximum and the minimum value of the following angles must be the same.
settings.OMEGA = 85*pi/180;                              % [rad] Maximum Elevation Angle, user input in degrees (ex. 80)
settings.PHI = 0*pi/180;                               % [rad] Maximum Azimuth Angle from North Direction, user input in degrees (ex. 90)



%% AEROBRAKES SETTINGS
% Multiple air-brakes and smooth opening simulation
settings.multipleAB = true;                               % If true, multiple and smooth airbrakes opening will be simulated

% If FALSE:
%       - settings.control: only the first value will be computed;
%       - settings.dtControl: is not read.
% If TRUE:
%       - settings.control: define the sequence of air-brakes opening
%                           configuration. Closed air-brakes are simulated
%                           untill the conditions settings.tControl and
%                           settings.machControl are both verified, check
%                           simulationsData.m;
%       - settings.dtControl: define the usage time of the i-th
%                             configuration. Its length must be -1 the
%                             length of settings.control

settings.control = [3 2 1];                         % aerobrakes, 1-2-3 for 0%, 50% or 100% opened
settings.dtControl = [2.8 2.9];                       % aerobrakes, configurations usage time


%% OPTIMIZATION

expectedApogee = 1500; %expected apogee based on telemetry
expectedMaxAcc = 80; %m/s^2
nFL = 4; %number of flight levels

velGround = 4; 

azimuthGround = 270; 

maxVel = 80; 
minVel = 0; 
maxDeltaVel = 30; %variazione [m/s]
minDeltaVel = -10; 

maxAz = 360; 
minAz = 0; 
maxDeltaAz = 30; % variazione azimut deg
minDeltaAz = -30; %deg 

tol = 1e-5; 
%% WIND DETAILS
% select which model you want to use:


%%%%% Matlab Wind Model
settings.wind.model = false;
% matlab hswm model, wind model on altitude based on historical data
% [m/s] Vertical wind speed

%%%%% Input wind
settings.wind.input = true;
% Wind is generated for every altitude interpolating with the coefficient defined below

settings.wind.inputGround = 4;                   % wind magnitude at the ground [m/s]
settings.wind.inputAlt = linspace(0, 2000, nFL+1);      % altitude vector [m]
settings.wind.inputMult = zeros(1, nFL+1);          % percentage of increasing magnitude at each altitude

settings.wind.inputAzimut = wrapTo360([azimuthGround, azimuthGround*ones(1, nFL)]+180);   % wind azimut angle at each altitude (toward wind incoming direction) [deg]

settings.wind.inputUncertainty = [0, 0];
% settings.wind.inputUncertainty = [a,b];      wind uncertanties:
% - a, wind magnitude percentage uncertanty: magn = magn *(1 +- a)
% - b, wind direction band uncertanty: dir = dir 1 +- b


% NOTE: wind azimuth angle indications (wind directed towards):
% 0 deg (use 360 instead of 0)  -> North
% 90 deg                        -> East
% 180 deg                       -> South
% 270 deg                       -> West


%% BOUNDARIES
% optimization vector x contains velocity and direction in each flight
% level





ub = [ maxVel * ones(1, nFL) , maxAz * ones(1, nFL) ]; 
lb = [ minVel * ones(1, nFL) , minAz * ones(1, nFL) ]; 

%% LINEAR COSTRAINTS

% voglio che ogni livello abbia un vento superiore al livello superiore ma
% che l'incremento sia contenuto, analogamente voglio che la rotazione tra
% livelli consecutivi sia contenuta
 
nVar = 2*nFL; 



A = zeros(5*nFL, nVar); 
b = zeros(5*nFL, 1); 

A(1, 1) = 1; 
A(2, 1) = -1; 
A(3, 1) = -1; 

A(3*nFL + 1, nFL +1) = 1; 
A(3*nFL + 2, nFL +1) = -1; 

b(1, 1) = maxDeltaVel + velGround; 
b(2, 1) = -minDeltaVel - velGround;
b(3, 1) = 0; 

b(3*nFL + 1, 1) = maxDeltaAz + azimuthGround; 
b(3*nFL + 2, 1) = -minDeltaAz - azimuthGround; 


for i = 2:nFL
    
    row1 = 3*i - 2; 
    col1 = i-1; 
    
    A(row1:row1+2, col1: col1+1) = [-1 1; 1 -1; 0 -1]; 
    b(row1:row1+2, 1) = [maxDeltaVel, -minDeltaVel, 0]'; 


    row2 = 3*nFL + 2*i - 1;  
    col2 = nFL + i - 1; 
    
    A(row2:row2+1, col2:col2+1) = [-1 1; 1 -1];
    b(row2:row2+1, 1) = [maxDeltaAz, -minDeltaAz]'; 
end

settings.A = A; 
settings.b = b; 

%% parallelization
settings.parpool = true; 

if settings.parpool
    parpool; 
end

%% COMPATIBILITY SETTINGS
% this settings are needed to work with the commonFunctions folder, do not
% modify it unless you now what you're doing
settings.stoch.N = 1;



