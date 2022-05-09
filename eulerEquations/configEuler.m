%{

CONFIG - This script sets up all the parameters for the simulation
All the parameters are stored in the "settings" structure.



Copyright © 2021, Skyward Experimental Rocketry, AFD department
All rights reserved

SPDX-License-Identifier: GPL-3.0-or-later

%}

%% MISSION FILE
% Choose the mision you want to simulate from rocketsData folder

%settings.mission = 'Lynx_Roccaraso_September_2021';
settings.mission = 'Lynx_Portugal_October_2021';

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


%% loading data

load logs_euroc.mat
clear cots

tCalc = 22.1; 
tol = 1e-3; 
tMax = 10 * 60; 

telem.angSpeedTime = stack.bmx_corrected.gyro.time;
telem.angSpeed.x = stack.bmx_corrected.gyro.gyro_x;
telem.angSpeed.y = stack.bmx_corrected.gyro.gyro_y;
telem.angSpeed.z = stack.bmx_corrected.gyro.gyro_z;

telem.angTime = stack.nas.eul.time; 
telem.angPith = unwrap(stack.nas.eul.pitch); 
telem.angRoll = unwrap(stack.nas.eul.roll); 
telem.angYaw = unwrap(stack.nas.eul.yaw); 


telem.airspeedTime = stack.pitot_calibrated.time; 
telem.airspeed = stack.pitot_calibrated.airspeed; 

[telem.zTime, telem.z] = tmaltitude(); 
% a = 0.0065;
% g = 9.80665;
% R = 287.05;
% n = g / (R * a);
% n_inv = (R * a) / g;
% gamma = 1.4; % Air adiabatic index
% rel_alt = @(p, pr, tr) tr / a * (1 - (p ./ pr) .^ n_inv);
% altitude = @(p) rel_alt(p, stack.altimter_calibration.P0, stack.altimter_calibration.T0) - stack.altimter_calibration.Zref;
% 
% telem.zTime = stack.ms5803.press.time;
% telem.z = altitude(stack.ms5803.press.press);


telem.velTime = stack.nas.vel.time;
telem.velX = stack.nas.vel.vel_x; 
telem.velY = stack.nas.vel.vel_y; 
telem.velZ = -stack.nas.vel.vel_z; 


%% parallelization
settings.parpool = false; 

if settings.parpool
    parpool; 
end

%% COMPATIBILITY SETTINGS
% this settings are needed to work with the commonFunctions folder, do not
% modify it unless you now what you're doing
settings.stoch.N = 1;



