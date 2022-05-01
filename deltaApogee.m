function d = deltaApogee(x, expectedApogee, expectedMaxAcc, settings)
    
    %retrive data

    nFL = length(x) / 2;  %length(x) is always an even number since it contains 2*nFL parameters
    settings.wind.inputMult = [0, (x(1:nFL)/settings.wind.inputGround - 1)*100];          % percentage of increasing magnitude at each altitude
    settings.wind.inputAzimut = [settings.wind.inputAzimut(1), x(nFL+1:end)];   % wind azimut angle at each altitude (toward wind incoming direction) [deg]
    
    [apogee, maxAcc] = quickApogeeOnlyMod(settings); 
    maxAcc = maxAcc*9.80665; 

    d = 0.8*abs(expectedApogee - apogee)/expectedApogee + 0.2*abs(expectedMaxAcc - maxAcc)/expectedMaxAcc;   %different weight for apogee and acceleration normalized

end