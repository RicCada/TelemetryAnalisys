function [apogee] = quickApogeeOnlyMod(settings)

%{
quickApogeeOnly - This function tests the fins simulating the ascent

INPUTS:
- settings,    struct (motor, CoeffsE, CoeffsF, para, ode, stoch, prob, wind), rocket data structure
                   

OUTPUTS:
- apogee,      double [1, 3], coordinates of the apogee;

CALLED FUNCTIONS: windConstGenerator.

REVISIONS:
- 0 14/10/2019, Release, Matteo Pozzoli

- 1 21/10/2020, Second version, Adriano Filippo Inno

- 2 03/10/2021, Update, Davide Rosato
                Multiple and smooth airbrakes opening added


Copyright © 2021, Skyward Experimental Rocketry, AFD department
All rights reserved

SPDX-License-Identifier: GPL-3.0-or-later

%}


%% ERROR CHECKING
if not(settings.multipleAB) && length(settings.control) > 1
    error('To simulate different airbrakes opening, please set to true settings.multipleAB in config.m');
end

if settings.multipleAB && length(settings.control) < 2
    error('In airbrakes smooth opening simulations, airbrakes configuration must be always greater than 2 (from launch), check config.m')
end

if settings.multipleAB && length(settings.control) > 1 && length(settings.dtControl) < length(settings.control) - 2
    error('In airbrakes smooth opening simulations, AB configuration usage time vector must be at least of length length(pCOntrol)-2, check config.m')
end


%% STARTING CONDITIONS

% Attitude
Q0 = angleToQuat(settings.PHI, settings.OMEGA, 0*pi/180)';

%% WIND GENERATION - removed generation of constant wind

% [uw, vw, ww] = windInputGenerator(settings.wind);
% settings.constWind = [uw, vw, ww];


tf = settings.ode.finalTime;

%% ASCENT
X0 = [0 0 0]';
V0 = [0 0 0]';
W0 = [0 0 0]';
Y0a = [X0; V0; W0; Q0; settings.Ixxf; settings.Iyyf; settings.Izzf];

if settings.multipleAB
    
    nAB = length(settings.control);
    t0 = 0;
    Ta = [];
    Ya = [];
    
    settings.delayControl = delayControl(settings.control, settings);
    
    for iAB = 1:nAB
        
        [Tab, Yab] = ode113(@ascentMultipleAB, [t0, tf], Y0a, settings.ode.optionsascMultipleAB, t0, iAB, settings);
        
        % update variables and the state
        t0 = Tab(end);
        Y0a = Yab(end, :);
        Ta = [Ta; Tab];
        Ya = [Ya; Yab];
        
    end
    
else
    [Ta, Ya] = ode113(@ascent, [0, tf], Y0a, settings.ode.optionsasc1, settings);
end

%% CALCULATE OUTPUT QUANTITIES
apogee = [Ya(end, 1), Ya(end, 2), -Ya(end, 3)];


