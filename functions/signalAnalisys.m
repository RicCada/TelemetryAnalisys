clear; 
clc; 
close all; 

loadData;



%%

iApoAG = length(find(timeAG < t_apogee));
iApo = length(find(time < t_apogee));

%%

Np1 = length(time(iApo:end)); 

fVPosN = freqVect(50, Np1); % frequency vector
trPosN = fourierTransform(time(iApo:end), posN(iApo:end)); 

fVVelN = freqVect(50, Np1); % frequency vector
trVelN = fourierTransform(time(iApo:end), vN(iApo:end)); 


Np2 = length(timeAG(1:iApoAG)); 

fVWY = freqVect(50, Np2); % frequency vector
trWY = fourierTransform(timeAG(1:iApoAG), wY(1:iApoAG));

fVPitch = freqVect(50, Np2); % frequency vector
trPitch = fourierTransform(timeAG(1:iApoAG), pitch(1:iApoAG));
%%

close all

figure(1); 
hold on; 
grid on; 
plot(fVPosN, trPosN, fVVelN, trVelN); 
legend('posD', 'velD'); 

figure(2); 
hold on; 
grid on; 
plot(fVPitch, trPitch, fVWY, trWY); 
legend('pitch', 'wY'); 

