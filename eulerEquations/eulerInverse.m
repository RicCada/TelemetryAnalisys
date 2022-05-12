function diff = eulerInverse(x, Y, settings)
    % x: vr velocità relativa al vento
    % Y: state

    %recalling the state
    
    %horizontal-frame velocities
    u = x(1); 
    v = x(2);
    w = settings.v0(3); 

    %body frame angular rates
    p = Y(1);
    q = Y(2);
    r = Y(3);
    
    %body fram angular acc
    p_dot = Y(4); 
    q_dot = Y(5); 
    r_dot = Y(6); 

    %attitude unit quaternion
    q0 = Y(7); 
    q1 = Y(8);
    q2 = Y(9);
    q3 = Y(10);

    %inertias
    Ixx = Y(11);
    Iyy = Y(12);
    Izz = Y(13);

    %height
    z = Y(14); 
    
    S = settings.S;                         % [m^2]   cross surface
    C = settings.C;                         % [m]     caliber
    g = settings.g0/(1 + (z*1e-3/6371))^2; % [N/kg]  module of gravitational field
    local = settings.Local;                 % vector containing inputs for atmosphereData


    Q = [q0, q1, q2, q3]; 
    Q = Q/norm(Q); 
    
    %quaternion attitude
    dcm = quatToDcm(Q); 
    
    vr = dcm*[u, v, w]'; 
    V_norm = norm(vr); 

    
    absoluteAltitude = z + settings.z0;
    [~, ~, ~, rho] = atmosphereData(absoluteAltitude, g, local);
    
    %retrive data from coeffs
    
    Coeffs = calcCoeffs(settings.z, vr, settings.tCalc, settings); 

    Cm = Coeffs(1); Cn = Coeffs(2); Cl = Coeffs(3); 
    Clp = Coeffs(4); Cmad = Coeffs(5); Cmq = Coeffs(6); 
    Cnr = Coeffs(7); Cnp = Coeffs(8); 


    % calc Aerodynamics torques
    
    L = 0.5 * rho * V_norm^2 * C * (Cl + (Clp * p * C)/(2*V_norm));           %   x-body
    M = 0.5 * rho * V_norm^2 * C * (Cm + (Cmad + Cmq)*(q * C)/(2 * V_norm));  %   y-body
    N = 0.5 * rho * V_norm^2 * C * (Cn + (Cnr*r + Cnp*p)*C/(2*V_norm));       %   z-body

    diff = [Ixx*p_dot + (Izz - Iyy)*q*r - L; ... 
            Iyy*q_dot + (Ixx - Izz)*p*r - M; ...
            Izz*r_dot + (Iyy - Ixx)*p*q - N]; 

end