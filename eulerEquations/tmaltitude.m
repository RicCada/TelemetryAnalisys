function [t_flight, agl_altitude_flight] = tmaltitude()



    t_liftoff = 2832195; % liftoff timestamp
    dt = 63;
    ref_altitude = 160;
    sysid = 171;
    compid = 96;
    
    hr_tm = readtable('../../../logs/2021-10-13-lynx-euroc/deathstack/telemetry/csv/hr_tm.csv');
    
    % check if packet is valid (sysid and compid set to 1)
    t = hr_tm.timestamp(hr_tm.sys_id == sysid & hr_tm.comp_id == compid);
    msl_altitude = hr_tm.msl_altitude(hr_tm.sys_id == sysid & hr_tm.comp_id == compid);
    agl_altitude = msl_altitude - ref_altitude;
    
    % get only packets after liftoff and shift them
    %t = t(t >= t_liftoff);
    t = t - t_liftoff;
    
    for i=1:length(t)
        if t(i) >= 0 
           t_flight(i) = t(i);
           agl_altitude_flight(i) = agl_altitude(i);
        end
    end
    

    t_flight = t_flight/1000; 


end

