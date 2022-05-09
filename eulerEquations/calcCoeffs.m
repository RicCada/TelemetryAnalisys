function Coeffs = calcCoeffs(z, v, t, settings)


    %retrive data
    g = settings.g0/(1 + (-z*1e-3/6371))^2; % [N/kg]  module of gravitational field
    local = settings.Local;   
    control = settings.control; %airbrakes control variable
    ur = v(1); 
    vr = v(2); 
    wr = v(3); 
    
    
    absoluteAltitude = z + settings.z0; 
    [~, a, ~, ~] = atmosphereData(absoluteAltitude, g, local);
    
    
    %supposing v = vr
    V_norm = norm(v); 
    
    M = V_norm / a; 
    
    
    
    %% AERODYNAMICS ANGLES
    if not(ur < 1e-9 || V_norm < 1e-9)
        alpha = atan(wr/ur);
        beta = atan(vr/ur);                         % beta = asin(vr/V_norm) is the classical notation, Datcom uses this one though.
        % alpha_tot = atan(sqrt(wr^2 + vr^2)/ur);   % datcom 97' definition
    else
        alpha = 0;
        beta = 0;
    end
    
    
    [coeffsValues, angle0] = interpCoeffs(t, alpha, M, beta, absoluteAltitude, control, settings);
    
    Cl = coeffsValues(6);
    Clp = coeffsValues(7); Cma = coeffsValues(8); Cm0 = coeffsValues(9);
    Cmad = coeffsValues(10); Cmq = coeffsValues(11); Cnb = coeffsValues(12);
    Cn0 = coeffsValues(13); Cnr = coeffsValues(14); Cnp = coeffsValues(15);
    
    % compute Cm, Cn (linearized with respect to alpha and beta)
    
    alpha0 = angle0(1); 
    beta0 = angle0(2); 
    
    Cm = Cm0 + Cma*(alpha - alpha0); 
    Cn = Cn0 + Cnb*(beta - beta0);
    
    Coeffs = [Cm, Cn, Cl, Clp, Cmad, Cmq, Cnr, Cnp]; 

end