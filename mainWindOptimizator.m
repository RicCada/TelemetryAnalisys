clc; 
clear all; 
close all; 


config; 
%% LOAD DATA
dataPath = strcat('../../msa-toolkit/data/', settings.mission);
addpath(dataPath);
str = '../../msa-toolkit/commonFunctions/'; 
addpath(genpath(str));   
simulationsData; 



%%

tol = 1/(0.8*expectedApogee + 0.2*expectedMaxAcc); 

options = optimoptions('ga', 'MaxStallGenerations', 10, 'FunctionTolerance', ...
    1/expectedApogee, 'MaxGenerations', 5, 'NonlinearConstraintAlgorithm', 'penalty',...
    'PopulationSize', 100, 'Display' ,  'iter' , 'UseParallel', settings.parpool, 'UseVectorized', false);

% Computational time needed


pool = gcp('nocreate'); % If no pool, do not create new one.


if isempty(pool)
    poolsize = 1;       % If no pool then # of workers is just 1
else
    poolsize = pool.NumWorkers;
end


% Perform optimization
tic
fitnessfcn = @(x) deltaApogee(x, expectedApogee,expectedMaxAcc, settings);

[x, fval, exitflag] = ga(fitnessfcn, nVar, A , b, [], [],...
    lb, ub, [], [], options);

computationalTime = toc;



delete(gcp('nocreate')) %shutting down parallel pool

%% print results
fprintf('COMPUTATIONAL EFFORT: \n\n')
fprintf('- Total time, %g [s]\n\n\n', computationalTime)

fprintf('WIND MAGNITUDE: \n')
fprintf('%f, %f, %f, %f \n\n', x(1), x(2), x(3), x(4)); 

fprintf('WIND DIRECTION: \n')
fprintf('%f, %f, %f, %f \n\n', x(5), x(6), x(7), x(8)); 





