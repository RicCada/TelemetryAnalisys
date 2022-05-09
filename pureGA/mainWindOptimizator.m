clc; 
clear; 
close all; 


config; 
%% LOAD DATA
dataPath = strcat('../../../MSA/msa-toolkit/data/', settings.mission);
addpath(dataPath);
str = '../../../MSA/msa-toolkit/commonFunctions/'; 
addpath(genpath(str));   
simulationsData; 



%%

options = optimoptions('ga', 'MaxStallGenerations', 20, 'FunctionTolerance', ...
    tol, 'MaxGenerations', 50, 'PopulationSize', 2000,'NonlinearConstraintAlgorithm', ...
     'penalty', 'Display' ,  'iter' , 'UseParallel', settings.parpool);

% Computational time needed


pool = gcp('nocreate'); % If no pool, do not create new one.


if isempty(pool)
    poolsize = 1;       % If no pool then # of workers is just 1
else
    poolsize = pool.NumWorkers;
end


% Perform optimization
tic

nonlcon = @(x) checkBound(x, settings); 

fitnessfcn = @(x) deltaApogee(x, expectedTarget, settings);

[x, fval, exitflag] = ga(fitnessfcn, nVar, [] , [], [], [],...
    lb, ub, nonlcon, [], options);

computationalTime = toc;



delete(gcp('nocreate')) %shutting down parallel pool

%% print results
fprintf('COMPUTATIONAL EFFORT: \n\n')
fprintf('- Total time, %g [s]\n\n\n', computationalTime)

fprintf('HEIGHT: \n'); 
fprintf('%f, %f, %f, %f, %f\n\n', settings.wind.inputAlt)

fprintf('WIND MAGNITUDE: \n')
fprintf('%f, %f, %f, %f \n\n', x(1), x(2), x(3), x(4)); 

fprintf('WIND DIRECTION: \n')
fprintf('%f, %f, %f, %f \n\n', x(5), x(6), x(7), x(8)); 



%{

HEIGHT: 
0.000000, 500.000000, 1000.000000, 1500.000000, 2000.000000

WIND MAGNITUDE: 
26.395296, 16.744240, 20.044560, 45.882702 

WIND DIRECTION: 
240.063739, 231.564822, 260.998110, 263.854985 

%}

