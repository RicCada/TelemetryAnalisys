clear; 
close all; 


config; 
%% LOAD DATA
dataPath = strcat('../../../MSA/msa-toolkit/data/', settings.mission);
addpath(dataPath);

simDataPath = '../../../MSA/msa-toolkit/commonFunctions/'; 
addpath(genpath(simDataPath));   

simulationsData; 
load logs_euroc.mat; 
clear cots

%% LOAD TELEMETRY
telem.accX = stack.bmx_corrected.acc.accel_x;
telem.accTime = stack.bmx_corrected.acc.time;

telem.velTime = stack.nas.vel.time; 
telem.velX = stack.nas.vel.vel_x;
telem.velY =stack.nas.vel.vel_y; 

telem.z = stack.ada.agl_altitude;
telem.vertSpeed = stack.ada.vert_speed;
telem.zTime = stack.ada.time;


telem.nasTime = stack.nas.pos.time;
%LAT = stack.gps.latitude;
%LON = stack.gps.longitude;

%wgs84 = wgs84Ellipsoid; 
%[telem.x,telem.y,down] = geodetic2ned(stack.gps.latitude, stack.gps.longitude, stack.gps.height, settings.lat0, settings.lon0, settings.z0, wgs84);
telem.x = stack.nas.pos.pos_x; 
telem.y = stack.nas.pos.pos_y; 



%% FIND ASCENT PHASE
telem.zMean = smooth(telem.z, 20, 'loess');


dtZ = telem.zTime(2) - telem.zTime(1);  %time step in z telemetry

tLiftoff = 0; 
tApogee = 0; 
expectedApogee = 0; 



N = floor(tCheck/dtZ);  %
for i = (1 : length(telem.zTime))
    
    if all(telem.zMean(i+1:i+N) > tolZ) && (telem.zMean(i) > 0)
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
telem.z = telem.z(indexLiftoff:indexApogee);
telem.zMean = telem.zMean(indexLiftoff:indexApogee);
telem.vertSpeed = telem.vertSpeed(indexLiftoff:indexApogee);


iL = find(telem.accTime >= tLiftoff, 1) - 1;
if (iL <= 0) iL = 1; end
iA = find(telem.accTime >= tApogee, 1) + 1; 
telem.accTime = telem.accTime(iL : iA); 
telem.accX = telem.accX(iL : iA ); 

iL = find(telem.velTime >= tLiftoff, 1) - 1; 
if (iL <= 0) iL = 1; end
iA = find(telem.velTime >= tApogee, 1) + 1; 
telem.velTime = telem.velTime(iL : iA); 
%telem.velX = smooth(telem.velX, 20, 'sgolay', 3); 
telem.velX = telem.velX(iL : iA); 
%telem.velY = smooth(telem.velY, 20, 'sgolay', 3); 
telem.velY = telem.velY(iL : iA); 


iL = find(telem.nasTime >= tLiftoff, 1) - 1; 
if (iL <= 0) iL = 1; end
iA = find(telem.nasTime >= tApogee, 1) + 1; 
telem.nasTime = telem.nasTime(iL:iA); 
telem.x = telem.x(iL : iA); 
telem.y = telem.y(iL : iA); 


%% select checkpoints for shooting method

tTarget = linspace(telem.zTime(1), telem.zTime(end), NcheckPoint); 
zTarget = interp1(telem.zTime, telem.zMean, tTarget, 'linear'); 



figure(1); 
plot(telem.nasTime, telem.x, telem.nasTime, telem.y, telem.zTime, telem.zMean); 
hold on; 
grid on; 
plot(tTarget, zTarget, 'o'); 
legend('x', 'y', 'z', 'target'); 


figure(2); 
plot(telem.velTime, telem.velX, telem.velTime, telem.velY, telem.zTime, telem.vertSpeed); 
hold on; 
grid on;  
legend('vx', 'vy', 'vz'); 


%check physical consistence
for i = (1 : NcheckPoint-1)

    
%     pi = round([interp1(telem.nasTime, telem.x, tTarget(i)), interp1(telem.nasTime, telem.y, tTarget(i)) , zTarget(i)]',3);
%     pf = round([interp1(telem.nasTime, telem.x, tTarget(i+1)), interp1(telem.nasTime, telem.y, tTarget(i+1)) , zTarget(i+1)]',3);
% 
%     vi = round([interp1(telem.velTime, telem.velX, tTarget(i)), interp1(telem.velTime, telem.velY, tTarget(i)), interp1(telem.zTime, telem.vertSpeed, tTarget(i))]',3);
%     vf = round([interp1(telem.velTime, telem.velX, tTarget(i+1)), interp1(telem.velTime, telem.velY, tTarget(i+1)), interp1(telem.zTime, telem.vertSpeed, tTarget(i+1))]',3);
% 
%     dt = tTarget(i+1) - tTarget(i); 
%     
%     vM = (pf - pi)/dt; 

    pi = round(zTarget(i),3);
    pf = round(zTarget(i+1),3);

    vi = round(interp1(telem.zTime, telem.vertSpeed, tTarget(i), 'linear'),3);
    vf = round(interp1(telem.zTime, telem.vertSpeed, tTarget(i+1), 'linear'),3);

    dt = tTarget(i+1) - tTarget(i); 
    
    vM = (pf - pi)/dt; 
    
%     c1 = xor(vM > vi*0.95, vM < vf*1.05 );
%     c2 = xor(vM < vi*1.05, vM > vf*0.95 ); 

    c1 = xor(vM > vi, vM < vf );
%    c2 = xor(vM < vi, vM > vf );

    [vi, vf, vM, c1]
    

end

zCalc = zeros(1, length(telem.zTime)); 
zCalc(1) = telem.z(1);
for i = (1: length(telem.zTime)-1)
    zCalc(i+1) = ((telem.zTime(i+1)-telem.zTime(i)) * telem.vertSpeed(i)) + telem.zMean(i);
end

figure(3); 
plot(telem.zTime, zCalc, telem.zTime, telem.zMean, telem.zTime, telem.z); 
hold on; 
grid on; 
legend('calc', 'ADA - smooth', 'ADA'); 











