clear; 
close all; 
addpath(genpath("..\functions")); 

loadData; %loading data

iApo = length(find(time < t_apogee));
iLand = length(find(time < t_landing));

% fetch value of interest only
timeI = time(iApo:iLand); 
vNI = vN(iApo:iLand);  
vEI = vE(iApo:iLand); 
vDI = vD(iApo:iLand); 

figure(1)
subplot(3, 1, 1)
plot(timeI, vNI); 
grid on
legend('vN', 'Location', 'best')

subplot(3, 1, 2); 
plot(timeI, vEI);
legend('vE', 'Location', 'best')
grid on

subplot(3, 1, 3)
plot(timeI, vDI);
legend('vD', 'Location', 'best')
grid on


posDI = posD(iApo:iLand);

gamma = asin(vDI ./ sqrt(vNI.^2 + vEI.^2 + vDI.^2)); 
vTot = sqrt(vNI.^2 + vEI.^2 + vDI.^2);

fil4 = fir1(4,0.001); 
gammaF = filter(fil4, 1, gamma);
vTotF = filter(fil4, 1, vTot); 

figure(2)
hold on
grid on
plot(timeI, gamma*180/pi); 
%plot(timeI, gammaF*180/pi, 'LineWidth',2)
legend('gamma', 'Location','best'); 

figure(3); 
hold on
grid on
plot(timeI, vTot); 
%plot(timeI, vTotF, 'LineWidth', 2); 
title('v Totale'); 

