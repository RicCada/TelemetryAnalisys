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












