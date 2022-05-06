function [dY] = ascentMod(t, Y, settings) 
    
    % recalling the states
    x = Y(1);
    y = Y(2);
    z = Y(3);
    u = Y(4);
    v = Y(5);
    w = Y(6);
    p = Y(7);
    q = Y(8);
    r = Y(9);
    q0 = Y(10);
    q1 = Y(11);
    q2 = Y(12);
    q3 = Y(13);
    Ixx = Y(14);
    Iyy = Y(15);
    Izz = Y(16);
    
    
    uw = settings.wind(1);  
    vw = settings.wind(2); 
    ww = 0;

    %% CONSTANTS
    S = settings.S;                         % [m^2]   cross surface
    C = settings.C;                         % [m]     caliber
    g = settings.g0/(1 + (-z*1e-3/6371))^2; % [N/kg]  module of gravitational field
    tb = settings.tb;                       % [s]     Burning Time
    local = settings.Local;                 % vector containing inputs for atmosphereData
    
    if settings.stoch.N > 1
        OMEGA = settings.stoch.OMEGA;
        uncert = settings.stoch.uncert;
        Day = settings.stoch.Day;
        Hour = settings.stoch.Hour;
        uw = settings.stoch.uw; vw = settings.stoch.vw; ww = settings.stoch.ww;
    else
        OMEGA = settings.OMEGA;
        uncert = [0, 0];
    
        if not(settings.wind.input) && not(settings.wind.model)
            uw = settings.constWind(1); vw = settings.constWind(2); ww = settings.constWind(3);
        end
    end
    
    % inertias for full configuration (with all the propellant embarqued) obtained with CAD's
    Ixxf = settings.Ixxf;        % [kg*m^2] Inertia to x-axis
    Iyyf = settings.Iyyf;        % [kg*m^2] Inertia to y-axis
    Izzf = settings.Izzf;        % [kg*m^2] Inertia to z-axis
    
    % inertias for empty configuration (all the propellant consumed) obtained with CAD's
    Ixxe = settings.Ixxe;        % [kg*m^2] Inertia to x-axis
    Iyye = settings.Iyye;        % [kg*m^2] Inertia to y-axis
    Izze = settings.Izze;        % [kg*m^2] Inertia to z-axis
    
    %% QUATERION ATTITUDE
    Q = [q0 q1 q2 q3];
    Q = Q/norm(Q);
    
    %% ADDING WIND (supposed to be added in NED axes - no vertical wind) 


    dcm = quatToDcm(Q);
    wind = dcm*[uw; vw; ww];
    
    % Relative velocities (plus wind);
    ur = u - wind(1);
    vr = v - wind(2);
    wr = w - wind(3);
    
    % Body to Inertial velocities
    Vels = dcm'*[u; v; w];
    V_norm = norm([ur vr wr]);
    
    %% ATMOSPHERE DATA
    if -z < 0     % z is directed as the gravity vector
        z = 0;
    end
    
    absoluteAltitude = -z + settings.z0;
    [~, a, P, rho] = atmosphereData(absoluteAltitude, g, local);
    
    M = V_norm/a;
    M_value = M;
    
    %% TIME-DEPENDENTS VARIABLES
    dI = 1/tb*([Ixxf Iyyf Izzf]' - [Ixxe Iyye Izze]');
    
    if t < tb
        m = settings.ms + interpLinear(settings.motor.expTime, settings.motor.expM, t);
        Ixxdot = -dI(1);
        Iyydot = -dI(2);
        Izzdot = -dI(3);
        T = interpLinear(settings.motor.expTime, settings.motor.expThrust, t);
    
    else     % for t >= tb the fligth condition is the empty one(no interpolation needed)
        m = settings.ms;
        Ixxdot = 0;
        Iyydot = 0;
        Izzdot = 0;
        T = 0;
    end
    
    %% AERODYNAMICS ANGLES
    if not(ur < 1e-9 || V_norm < 1e-9)
        alpha = atan(wr/ur);
        beta = atan(vr/ur);                         % beta = asin(vr/V_norm) is the classical notation, Datcom uses this one though.
        % alpha_tot = atan(sqrt(wr^2 + vr^2)/ur);   % datcom 97' definition
    else
        alpha = 0;
        beta = 0;
    end
    
    alpha_value = alpha;
    beta_value = beta;
    
    %% CHOSING THE EMPTY CONDITION VALUE
    % interpolation of the coefficients with the value in the nearest condition of the Coeffs matrix
    
    if t >= settings.tControl && M <= settings.MachControl
    
        switch settings.control
            case 1
                c = 1;
    
            case 2
                c = 2;
    
            case 3
                c = 3;
        end
    
    else
        c = 1;
    end
    
    %% INTERPOLATE AERODYNAMIC COEFFICIENTS:
    
    [coeffsValues, angle0] = interpCoeffs(t, alpha, M, beta, absoluteAltitude,...
        c, settings);
    
    % Retrieve Coefficients
    CA = coeffsValues(1); CYB = coeffsValues(2); CY0 = coeffsValues(3);
    CNA = coeffsValues(4); CN0 = coeffsValues(5); Cl = coeffsValues(6);
    Clp = coeffsValues(7); Cma = coeffsValues(8); Cm0 = coeffsValues(9);
    Cmad = coeffsValues(10); Cmq = coeffsValues(11); Cnb = coeffsValues(12);
    Cn0 = coeffsValues(13); Cnr = coeffsValues(14); Cnp = coeffsValues(15);
    % XCP_value = coeffsValues(16);
    
    % compute CN,CY,Cm,Cn (linearized with respect to alpha and beta):
    alpha0 = angle0(1); beta0 = angle0(2);
    
    CN = (CN0 + CNA*(alpha - alpha0));
    CY = (CY0 + CYB*(beta - beta0));
    Cm = (Cm0 + Cma*(alpha - alpha0));
    Cn = (Cn0 + Cnb*(beta - beta0));
    
    XCPlon = Cm/CN;
    XCPlat = Cn/CY;
    
    if Cn == 0 && CY == 0
        XCPlat = -5;
    end
    
    %%
    if -z < settings.lrampa*sin(OMEGA)      % No torque on the launchpad
    
        Fg = m*g*sin(OMEGA);                % [N] force due to the gravity
        X = m*accX;
        F = -Fg +T -X;
        du = F/m;
    
        dv = 0;
        dw = 0;
        dp = 0;
        dq = 0;
        dr = 0;
    
        alpha_value = NaN;
        beta_value = NaN;
        Y = 0;
        Z = 0;
        XCPlon = NaN;
        XCPlat = NaN;
    
        if T < Fg                           % No velocity untill T = Fg
            du = 0;
        end
    
    else
    %% FORCES
        % first computed in the body-frame reference system
        qdyn = 0.5*rho*V_norm^2;            % [Pa] dynamics pressure
        qdynL_V = 0.5*rho*V_norm*S*C;
    
        X = m*accX;              % [N] x-body component of the aerodynamics force - FROM TELEMETRY
        Y = qdyn*S*CY;                      % [N] y-body component of the aerodynamics force
        Z = qdyn*S*CN;                      % [N] z-body component of the aerodynamics force
        Fg = dcm*[0; 0; m*g];               % [N] force due to the gravity in body frame
    
        F = Fg + [X , Y, -Z]';             % [N] total forces vector
    
    %% STATE DERIVATIVES
        % velocity
        du = F(1)/m - q*w + r*v;
        dv = F(2)/m - r*u + p*w;
        dw = F(3)/m - p*v + q*u;
    
        % Rotation
        dp = (Iyy - Izz)/Ixx*q*r + qdynL_V/Ixx*(V_norm*Cl+Clp*p*C/2) - Ixxdot*p/Ixx;
        dq = (Izz - Ixx)/Iyy*p*r + qdynL_V/Iyy*(V_norm*Cm + (Cmad+Cmq)*q*C/2)...
            - Iyydot*q/Iyy;
        dr = (Ixx - Iyy)/Izz*p*q + qdynL_V/Izz*(V_norm*Cn + (Cnr*r+Cnp*p)*C/2)...
            - Izzdot*r/Izz;
    
    end
    % Quaternions
    OM = [ 0 -p -q -r  ;
           p  0  r -q  ;
           q -r  0  p  ;
           r  q -p  0 ];
    
    dQQ = 1/2*OM*Q';
    
    %% FINAL DERIVATIVE STATE ASSEMBLING
    dY(1:3) = Vels;
    dY(4) = du;
    dY(5) = dv;
    dY(6) = dw;
    dY(7) = dp;
    dY(8) = dq;
    dY(9) = dr;
    dY(10:13) = dQQ;
    dY(14) = Ixxdot;
    dY(15) = Iyydot;
    dY(16) = Izzdot;
    dY = dY';
   
end