function der = derivativeMOD(time, val, fS, maxRatio)

    
    Np = length(time); 
    fv = freqVect(fS, Np);
    tr = fourierTransform(time, val); 
    %fourier transformed signal in order to get the armonic content
    
    fIndex = find(tr >= maxRatio, 1, 'last'); 
    fN = 2*fv(fIndex); 
    
    if fN >= fS
        fN = fS; 
    end
        
    tL = time(end) - time(1);  
    nS = tL * fN;  %number of samples

    timeSP = linspace(time(1), time(end), nS); 
    valSP = interp1(time, val, timeSP); 

    valFin = spline(timeSP, valSP, time); 


    figure
    hold on
    grid on
    plot(time, val); 
    plot(time, valFin, 'LineWidth',2);
    plot(timeSP, valSP, 'O', 'MarkerSize', 5)

    legend('RAW', 'SPLINE'); 
    
    
    der = zeros(1, length(valFin)); 
    
    
    der(1) = (valFin(2) - valFin(1))/(time(2) - time(1)); 

    for i = (2:length(time)-1)
        
        der(i) = (valFin(i+1) - valFin(i-1)) / ( time(i+1) - time(i-1) ); 
    
    end

    der(end) = (valFin(end) - valFin(end-1))/(time(end) - time(end-1)); 
    


end