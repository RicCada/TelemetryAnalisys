
load dataRoccaraso.mat


% fetch gyro/acc data
timeAG = data.timeAccGyro; 

wX = data.omega_bodyX; 
wY = data.omega_bodyY; 
wZ = data.omega_bodyZ; 

aX = data.a_bodyX; 
aY = data.a_bodyY; 
aZ = data.a_bodyZ; 


% fetch position/velocity data 
time = data.timePVQB; 

posN = data.n(1:end-1); 
posE = data.e(1:end-1); 
posD = data.d(1:end-1);  % position NED frame

vN = data.v_n(1:end-1); 
vE = data.v_e(1:end-1); 
vD = data.v_d(1:end-1);  % velocity NED frame

Q = [data.q_w(1:end-1)', data.q_x(1:end-1)', data.q_y(1:end-1)', data.q_z(1:end-1)']; % quaterion
[yaw, pitch, roll] = quat2angle(Q); %Euler angle
yaw = unwrap(yaw'); 
pitch = unwrap(pitch'); 
roll = unwrap(roll'); 


% fetch events
t_liftoff = data.events.t_liftoff; 
t_apogee = data.events.t_apogee; 
t_maindepl = data.events.t_maindepl;
t_landing = data.events.t_landing; 

clear data; 






