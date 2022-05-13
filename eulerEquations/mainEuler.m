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



%% CLEAN DATA



telem.angSpeed.x = movmean(telem.angSpeed.x, 30); 
telem.angSpeed.y = movmean(telem.angSpeed.y, 30); 
telem.angSpeed.z = movmean(telem.angSpeed.z, 30); 

q = gradient(movmean(telem.angPitch,30)); 

telem.angAcc.x = gradient(telem.angSpeed.x); 
telem.angAcc.y = gradient(telem.angSpeed.y);
telem.angAcc.z = gradient(telem.angSpeed.z);

figure(1); 
plot(telem.angSpeedTime, telem.angSpeed.y, telem.angTime, q)
legend('p telem', 'p calc'); 

%% retrive data
tCalc =2 ; 

Ixx = settings.Ixxe; 
Iyy = settings.Iyye; 
Izz = settings.Izze;

data = getTelemetryData(tCalc, telem); 


z = data(1);  
p = data(2); q = data(3); r = data(4); 
p_dot = data(5); q_dot = data(6); r_dot = data(7); 
pitch = data(8); roll = data(9); yaw = data(10); 
vx = data(11); vy = data(12); vz = data(13); 

vH_telem = [vx, vy, vz]'; 

Q = angle2quat(pitch, roll, yaw, 'YXZ'); 
Y = [p, q, r, p_dot, q_dot, r_dot, Q(1), Q(2), Q(3), Q(4), Ixx, Iyy, Izz, z]; %STATE VECTOR


wind = [2;5 ; 0]; 
vr = vH_telem - wind; 



%% perform calc
settings.v0 = vH_telem; %velocity
settings.z = z; 
settings.tCalc = tCalc; 

eulerInverse([vr(1); vr(2)], Y, settings)

res = tolRes - 1; 
time = 0; 
options = optimoptions('fsolve', 'Display', 'off', 'Algorithm', 'Levenberg-Marquardt'); 


x0 = [vx, vy]';  %optimization variable

tic
while ((res > tolRes) && (time < tMax))
    fun = @(x) eulerInverse(x, Y, settings); 
    
    [xCalc, diff] = fsolve(fun, x0, options); 
    
    res = max(abs(diff)); 
    
    x0 = settings.vMinR + (settings.vMaxR - settings.vMinR) * rand(2, 1);   
    
    
    [[xCalc; vH_telem(3)],  [x0; vH_telem(3)], diff]
    

    time = toc; 
end

toc












