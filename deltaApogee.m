function d = deltaApogee(x, expectedApogee, expectedMaxAcc, settings)
    
    %retrive data
    
    nFL = length(x) / 2;  %length(x) is always an even number since it contains 2*nFL parameters
    settings.wind.inputMult = [0, x(2:nFL)];          % percentage of increasing magnitude at each altitude
    settings.wind.inputAzimut = [settings.wind.inputAzimut, x(nFL+1:end)];   % wind azimut angle at each altitude (toward wind incoming direction) [deg]
    
    [apogee, maxAcc] = quickApogeeOnlyMod(settings); 
    

    d = 0.8*abs(expectedApogee - apogee)/expectedApogee + 0.2*abs(expectedMaxAcc - maxAcc)/expectedMaxAcc;   %different weight for apogee and acceleration normalized
    d = -1 * d; %get a minimization problem
end