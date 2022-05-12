function [c, ceq] = checkVelocity(x, settings)
    
    ceq = []; 
    

    
    vMin = settings.vMinR; 
    vMax = settings.vMaxR;
    
    vCalc = [x(1), x(2), settings.v0(3)]; 
    
    if norm(vCalc) > vMax
        c = norm(vCalc) + vMax; 
    elseif norm(vCalc) <vMin
        c = vMin + norm(vCalc); 
    else
        c = norm(vCalc) - vMax; 
    end


end