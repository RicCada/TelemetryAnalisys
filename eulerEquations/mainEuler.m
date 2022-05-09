close all; 
clear; 

%% LOAD DATA
dataPath = strcat('../../../MSA/msa-toolkit/data/', settings.mission);
addpath(dataPath);
str = '../../../MSA/msa-toolkit/commonFunctions/'; 
addpath(genpath(str));   
simulationsData; 

%% run config

configEler; 

%% perform calculations

tic;
while (res > tol) && (time < tMax)
    
    settings.vr = x; 

    f = @(x) eulerInverse(x, settings); 

    time = toc; 

end
