clc; 
clear all; 
close all; 

%%
path = '../../msa-toolkit'; 
addpath(path);   

%%

 if settings.wind.model && settings.wind.input
    error('Both wind model and input wind are true, select just one of them')
end

if settings.multipleAB && length(settings.control) > 1 && length(settings.dtControl) < length(settings.control) - 1
    error('In airbrakes smooth opening simulations, AB configuration usage time vector must be at least of length length(pCOntrol)-1, check config.m')
end
    
if settings.wind.HourMin ~= settings.wind.HourMax || settings.wind.DayMin ~= settings.wind.DayMax
    error('In standard simulations with the wind model the day and the hour of launch must be unique, check config.m')
end

if settings.OMEGAmin ~= settings.OMEGAmax || settings.PHImin ~= settings.PHImax
    error('In a single simulation the launchpad configuration has to be unique, check config.m')
end

if settings.para(settings.Npara).z_cut ~= 0 
    error('The landing will be not achived, check the final altitude of the last parachute in config.m')
end

if settings.upwind
    error('Upwind is available just in stochastich simulations, check config.m');
end

if settings.wind.input && not(all(settings.wind.inputUncertainty == 0))
    error('settings.wind.inputUncertainty is available just in stochastich simulations, set it null')
end