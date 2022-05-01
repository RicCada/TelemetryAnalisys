function [c, ceq] = checkBound(x, settings)
    
    

    if settings.A * x' < settings.b
        ceq = 0; 
        c = -10; 
    else
        ceq = 10;
        c = 10; 
    end
    
end