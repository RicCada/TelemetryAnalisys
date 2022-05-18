function y = derivative(u,dt)
    % Input
    % u - row vector to derivate
    % t - space between points
    % Output
    % y - derivative of the row vector u
    % Comment
    %We use weighted finite difference obtained from this pdf
    %https://www.ams.org/journals/mcom/1988-51-184/S0025-5718-1988-0935077-0/S0025-5718-1988-0935077-0.pdf
    
    [~,n]=size(u); 
    y=zeros(1,n);
    
    for i = (1:4) %Forward finite difference
        y(i)=( -147*u(i)+360*u(i+1)-450*u(i+2)+400*u(i+3)-225*u(i+4)+72*u(i+5)-10*u(i+6) )/(60*dt);  
    end
    
    for i = (5:n-4) %Center finite difference
        y(i)=( 3*u(i-4)- 32*u(i-3)+ 168*u(i-2)- 672*u(i-1) + 672*u(i+1) - 168*u(i+2) + 32*u(i+3) - 3*u(i+4) )/(840*dt); 
    end
    
    for i = n-3:n %Backward finite difference
        y(i)=( 147*u(i)-360*u(i-1)+450*u(i-2)-400*u(i-3)+225*u(i-4)-72*u(i-5)+10*u(i-6) )/(60*dt); 
    end
    
end