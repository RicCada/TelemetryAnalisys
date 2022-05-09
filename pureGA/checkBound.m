function [c, ceq] = checkBound(x, settings)
    
    

    ceq = [];

    res = settings.A * x' - settings.b; 

    if res < 0 %OK
        c = sum(res);  
    else %WASTE
        c = 0; 
    
        for i = (1:length(res))
            if res(i) > 0
                c = c + res(i); 
            end
        end
    end
    
end