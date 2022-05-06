function [err] = deltaPoint(x, settings)

%{
        x: [uw, vw]
        
        settings:   - Y0
                    - expectedTime
                    - expectedPoint
                    - accX
                    - telemetry [x, y, z]


%}


    %% recall data

    Y0 = settings.Y0; 
    
    settings.wind = x; 

    [t, Y] = ode113(@ascentMod, tInt, Y0, [], settings);
    
    err = norm(Y(end, 1:3)' - settings.expectedPoint); 



end

