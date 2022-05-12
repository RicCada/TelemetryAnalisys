close all; 
clear; 

%% run config
configEuler; 


%% LOAD DATA
dataPath = strcat('../../../msa-toolkit/data/', settings.mission);
addpath(dataPath);
str = '../../../msa-toolkit/commonFunctions/'; 
addpath(genpath(str));   
simulationsData; 



%% check

% for i = (1 : length(telem.zTime)-1)
%     
%     if telem.zTime(i) >= 24
%         break; 
%     end
%     pi = round(telem.z(i),3);
%     pf = round(telem.z(i+1),3);
%     
%     
%     vi = round(interp1(telem.velTime, telem.velZ, telem.zTime(i), 'linear'),3);
%     vf = round(interp1(telem.velTime, telem.velZ, telem.zTime(i), 'linear'),3);
% 
%     dt = telem.zTime(i+1) - telem.zTime(i); 
%     
%     vM = (pf - pi)/dt; 
% 
%     c1 = xor(vM > vi, vM < vf );
% 
%     [vi, vf, vM, c1];
%     
% 
% end



telem.angSpeed.x = movmean(telem.angSpeed.x, 30); 
telem.angSpeed.y = movmean(telem.angSpeed.y, 30); 
telem.angSpeed.z = movmean(telem.angSpeed.z, 30); 

pdotVect = gradient(telem.angSpeed.x); 
qdotVect = gradient(telem.angSpeed.y);
rdotVect = gradient(telem.angSpeed.z);
%% perform calculations
tCalc = 20 ; 

z = interpLinear(telem.zTime, telem.z, tCalc); 

p = interpLinear(telem.angSpeedTime, telem.angSpeed.x, tCalc);
q = interpLinear(telem.angSpeedTime, telem.angSpeed.y, tCalc);
r = interpLinear(telem.angSpeedTime, telem.angSpeed.z, tCalc);

p_dot = interpLinear(telem.angSpeedTime, pdotVect, tCalc);
q_dot = interpLinear(telem.angSpeedTime, qdotVect, tCalc);
r_dot = interpLinear(telem.angSpeedTime, rdotVect, tCalc);

pitch = interpLinear(telem.angTime, telem.angPith, tCalc); 
roll = interpLinear(telem.angTime, telem.angRoll, tCalc); 
yaw = interpLinear(telem.angTime, telem.angYaw, tCalc); 

vx = interpLinear(telem.velTime, telem.velX, tCalc);
vy = interpLinear(telem.velTime, telem.velY, tCalc);
vz = interpLinear(telem.velTime, telem.velZ, tCalc);

vH_telem = [vx, vy, vz]'; 

Q = angle2quat(pitch, roll, yaw, 'YXZ'); 


Ixx = settings.Ixxe; 
Iyy = settings.Iyye; 
Izz = settings.Izze;



x0 = [vx, vy]';  %optimization variable
settings.v0 = vH_telem; %velocity
settings.z = z; 
settings.tCalc = tCalc; 

Y = [p, q, r, p_dot, q_dot, r_dot, Q(1), Q(2), Q(3), Q(4), Ixx, Iyy, Izz, z]; %STATE VECTOR

res = 100; 
time = 0; 
options = optimoptions('fsolve', 'Display', 'off', 'Algorithm', 'Levenberg-Marquardt'); 
tic
while ((res > tolRes) && (time < tMax))
    fun = @(x) eulerInverse(x, Y, settings); 
    
    [xCalc, diff] = fsolve(fun, x0, options); 
    
    res = max(abs(diff)); 
    
    x0 = settings.vMinR + (settings.vMaxR - settings.vMinR) * rand(2, 1);   
    
    
    [xCalc,  x0]
    diff

    time = toc; 
end














