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


%% perform calculations
tCalc = 22.2; 

z = interpLinear(telem.zTime, telem.z, tCalc); 

p = interpLinear(telem.angSpeedTime, telem.angSpeed.x, tCalc);
q = interpLinear(telem.angSpeedTime, telem.angSpeed.y, tCalc);
r = interpLinear(telem.angSpeedTime, telem.angSpeed.z, tCalc);

p_dot = gradient(p); 
q_dot = gradient(q);
r_dot = gradient(r); 

pitch = interpLinear(telem.angTime, telem.angPith, tCalc); 
roll = interpLinear(telem.angTime, telem.angRoll, tCalc); 
yaw = interpLinear(telem.angTime, telem.angYaw, tCalc); 

vx = interpLinear(telem.velTime, telem.velX, tCalc);
vy = interpLinear(telem.velTime, telem.velY, tCalc);
vz = interpLinear(telem.velTime, telem.velZ, tCalc);

v0 = [vx, vy, vz]'; 

Q = angle2quat(pitch, roll, yaw, 'YXZ'); 


Ixx = settings.Ixxe; 
Iyy = settings.Iyye; 
Izz = settings.Izze;


res = v0; 
time = 0 ;



tic;
while (max(abs(res)) > tol) && (time < tMax)
    
    Q = Q/norm(Q); 
    dcm = quat2dcm(Q); 

    vr = dcm*v0; 
    Coeffs = calcCoeffs(z, vr, tCalc, settings);
    

    Y = [p, q, r, p_dot, q_dot, r_dot, Q(1), Q(2), Q(3), Q(4), Ixx, Iyy, Izz, z]; 


    f = @(x) eulerInverse(x, Y, Coeffs, settings); 
    
    v1 = fminunc(f, v0); %horizontal body frame

    res = v1 - v0;
    
    v0 = v1; 

    time = toc; 

end

vr = v0


















