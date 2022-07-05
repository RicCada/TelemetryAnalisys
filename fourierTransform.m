function trP = fourierTransform(time,signal)

Np = length(time); 

tr = abs(fft(signal)); %transform


if (mod(Np,2) == 0)
    trP = [tr(1), 2*tr(2:Np/2)]; 
else 
    trP = [tr(1), 2*tr(2: floor(Np/2)+1)]; 
end

m = max(trP); 

trP = trP/m; 

end