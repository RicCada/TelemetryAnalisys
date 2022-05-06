clc; 
clear; 
close all; 


config; 
%% LOAD DATA
dataPath = strcat('../../../msa-toolkit/data/', settings.mission);
addpath(dataPath);
str = '../../../msa-toolkit/commonFunctions/'; 
addpath(genpath(str));   
simulationsData; 


%USARE latlon2local
% fminunc / fmincon
