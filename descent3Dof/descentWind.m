function res = descentWind(x, Y, settings)
%{

RES: wind magnitude
x: inertial velocities (x,y)
Y: rocket state [accX_NED, accY_NED, accZ_NED, vZ_NED, z_NED]

IN THIS ANALYSIS THE WIND IS SUPPOSED HORIZONTAL, SO vZ_Aer is supposed equal to vZ_NED

%}



% x = Y(1);
% y = Y(2);
u = x(1);
v = x(2);
w = settings.v0;

accX = Y(1); 
accY = Y(2); 
accZ = Y(3); %accelarations 3DOF
z = Y(4);   %state data

%% CONSTANTS


S = settings.para(para).S;                                               % [m^2]   Surface
CD = settings.para(para).CD;                                             % [/] Parachute Drag Coefficient
%CL = settings.para(para).CL;                                             % [/] Parachute Lift Coefficient
if para == 1
    pmass = 0 ;                                                          % [kg] detached mass
else
    pmass = sum(settings.para(1:para-1).mass) + settings.mnc;
end

g = 9.80655;                                                             % [N/kg] magnitude of the gravitational field at zero
m = settings.ms - pmass;                                                 % [kg] descend mass


%% ATMOSPHERE DATA
if -z < 0        % z is directed as the gravity vector
    z = 0;
end

absoluteAltitude = -z + settings.z0;
[~, ~, P, rho] = atmosphereData(absoluteAltitude, g, local);

%% REFERENCE FRAME

eX = [1 0 0]; 
eY = [0 1 0];
eZ = [0 0 1]; 

vel = [u, v, w]; 

accXY = sqrt(accX^2 + accY^2); 


gamma = asin( dot(eZ, vel)/norm(vel) ); 






end