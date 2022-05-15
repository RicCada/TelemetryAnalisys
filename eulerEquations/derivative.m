function [y] = derivative(u,t)
    % Input
    % u - row vector to derivate
    % t - space between points
    % Output
    % y - derivative of the row vector u
    % Comment
    %We use weighted finite difference obtained from this pdf
    %https://www.ams.org/journals/mcom/1988-51-184/S0025-5718-1988-0935077-0/S0025-5718-1988-0935077-0.pdf
    [~,n]=size(u); y=zeros(1,n);
    for i=1:1:3 %Forward finite difference
    y(~,i)=( -147*u(1,i)+360*u(1,i+1)-450*u(1,i+2)+400*u(1,i+3)-225*u(1,i+4)+72*u(1,i+5)-10*u(1,i+6) )/(60*t);  
    end
    for i=4:1:n-4 %Center finite difference
    y(~,i)=( 3*u(1,i-4)-32*u(1,i-3)+168*u(1,i-2)-672*u(1,i-1)+672*u(1,i+1)-168*u(1,i+2)+32*u(1,i+3)-3*u(1,i+4))/(840*t); 
    end
    for i=n-3:1:n %Backward finite difference
    y(~,i)=( 147*u(1,i)-360*u(1,i-1)+450*u(1,i-2)-400*u(1,i-3)+225*u(1,-4)-72*u(1,i-5)+10*u(1,i-6) )/(60*t); 
    end
    
    end