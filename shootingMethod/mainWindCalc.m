clc; 
clear; 
close all; 


config; 
%% LOAD DATA
dataPath = strcat('../../../msa-toolkit/data/', settings.mission);
addpath(dataPath);

simDataPath = '../../../msa-toolkit/commonFunctions/'; 
addpath(genpath(simDataPath));   

simulationsData; 
load logs.mat; 
clear cots

%% LOAD TELEMETRY
telem.accX = stack.bmx_corrected.acc.accel_x;
telem.accTime = stack.bmx_corrected.acc.time;

telem.velTime = stack.pitot.time; 
telem.velX = stack.pitot.airspeed;

telem.z = stack.ada.agl_altitude;
telem.vertSpeed = stack.ada.vert_speed;
telem.zTime = stack.ada.time;


telem.gpsTime = stack.gps.time;
LAT = stack.gps.latitude;
LON = stack.gps.longitude;

wgs84 = wgs84Ellipsoid; 
[telem.x,telem.y,down] = geodetic2ned(stack.gps.latitude, stack.gps.longitude, stack.gps.height, settings.lat0, settings.lon0, settings.z0, wgs84);

%% FIND ASCENT PHASE



dtZ = telem.zTime(2) - telem.zTime(1);  %time step in z telemetry

tLiftoff = 0; 
tApogee = 0; 
expectedApogee = 0; 



N = floor(tCheck/dtZ);  %
for i = (1 : length(telem.zTime))
    
    if all(telem.z(i+1:i+N) > tolZ)
        tLiftoff = telem.zTime(i); 
        indexLiftoff = i; 
        break; 
    end

end


for i = (indexLiftoff:length(telem.vertSpeed))
    if all(telem.vertSpeed(i-N:i) > 0) && all(telem.vertSpeed(i+1:i+N) < 0)
        tApogee = telem.zTime(i); 
        expectedApogee = telem.z(i); 
        indexApogee = i; 
        break; 
    end
end

%% select ASCENT PHASE
telem.zTime = telem.zTime(indexLiftoff:indexApogee);
telem.zMean = smooth(telem.z, 20, 'loess'); 
telem.z = telem.z(indexLiftoff:indexApogee);
telem.vertSpeed = telem.vertSpeed(indexLiftoff:indexApogee);


iL = find(telem.accTime >= tLiftoff, 1); 
iA = find(telem.accTime >= tApogee, 1); 
telem.accTime = telem.accTime(iL : iA); 
telem.accX = telem.accX(iL : iA ); 

iL = find(telem.velTime >= tLiftoff, 1); 
iA = find(telem.velTime >= tApogee, 1); 
telem.velTime = telem.velTime(iL : iA); 
telem.velX = smooth(telem.velX, 20, 'sgolay', 3); 
telem.velX = telem.velX(iL : iA); 


iL = find(telem.gpsTime >= tLiftoff, 1); 
iA = find(telem.gpsTime >= tApogee, 1); 
telem.gpsTime = telem.gpsTime(iL:iA); 
telem.x = telem.x(iL : iA); 
telem.y = telem.y(iL : iA); 


%% select checkpoints for shooting method

tTarget = linspace(telem.zTime(1), telem.zTime(end), NcheckPoint); 
zTarget = interp1(telem.zTime, telem.z, tTarget, 'linear'); 



%% solve the problem

%{
    x: GPS
    y: GPS
    z: ADA
    

%}












