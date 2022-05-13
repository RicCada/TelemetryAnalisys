function data = getTelemetryData(t, telem)
% data = getTelemetryData(t, telem) retrive useful data from telemety
%     
%   Output: 
%       data = [z, p, q, r, p_dot, q_dot, r_dot, pitch, roll, yaw, vx, vy,
%       vz]; 


    z = interpLinear(telem.zTime, telem.z, t); 

    p = interpLinear(telem.angSpeedTime, telem.angSpeed.x, t);
    q = interpLinear(telem.angSpeedTime, telem.angSpeed.y, t);
    r = interpLinear(telem.angSpeedTime, telem.angSpeed.z, t);
    
    p_dot = interpLinear(telem.angSpeedTime, telem.angAcc.x, t);
    q_dot = interpLinear(telem.angSpeedTime, telem.angAcc.y, t);
    r_dot = interpLinear(telem.angSpeedTime, telem.angAcc.z, t);
    
    pitch = interpLinear(telem.angTime, telem.angPitch, t); 
    roll = interpLinear(telem.angTime, telem.angRoll, t); 
    yaw = interpLinear(telem.angTime, telem.angYaw, t); 
    
    vx = interpLinear(telem.velTime, telem.velX, t);
    vy = interpLinear(telem.velTime, telem.velY, t);
    vz = interpLinear(telem.velTime, telem.velZ, t);


    data = [z, p, q, r, p_dot, q_dot, r_dot, pitch, roll, yaw, vx, vy, vz]; 
end