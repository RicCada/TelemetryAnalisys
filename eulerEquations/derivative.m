function [y] = derivative(u,t)
    % Ingresso
    % u - vettore riga abbastanza grande di cui vogliamo la derivata
    % t - spazio tra una valutazione e l'altra
    % Uscita
    % y - vettore riga derivata prima
    % Commenti
    %Utilizzo la formula alle differenze centrate, aggiungendo quattro punti all'inizio uguali a zero
    %(perchè il razzo deve ancora partire) e negli ultimi cinque elementi si
    %usano invece le differenze all'indietro. Pesi tratti da:
    %https://www.ams.org/journals/mcom/1988-51-184/S0025-5718-1988-0935077-0/S0025-5718-1988-0935077-0.pdf
    [~,n]=size(u); y=zeros(1,n);
    u=[0,0,0,0,u]; % Il razzo parte da fermo
    for i=1:1:n-4
    y(1,i)=( 3*u(1,i)-32*u(1,i+1)+168*u(1,i+2)-672*u(1,i+3)+672*u(1,i+5)-168*u(1,i+6)+32*u(1,i+7)-3*u(1,i+8))/(840*t); 
    end
    for i=n-3:1:n %(per gli ultimi 4 termini usiamo metodo differenze indietro)
    y(1,i)=( 147*u(1,i+4)-360*u(1,i+3)+450*u(1,i+2)-400*u(1,i+1)+225*u(1,i)-72*u(1,i-1)+10*u(1,i-2) )/(60*t); 
    end
    
    end