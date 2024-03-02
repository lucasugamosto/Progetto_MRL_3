function finalV = speedControl(currentV, newV)
    %funzione che riceve in ingresso le componenti di velocità lungo x ed y
    %e controlla se sono rispettate le condizioni seguenti:
    % - velocità non negative
    % - velocità minore di 5
    % - al massimo una componente di velocità nulla

    %Controllo del valore minimo ammissibile per la velocità
    if (newV(1) < 0 && newV(2) > 0)         %Se componente lungo x è negativa
        newV(1) = 0;
    elseif (newV(1) > 0 && newV(2) < 0)     %Se componente lungo y è negativa
        newV(2) = 0;
    elseif (newV(1) <= 0 && newV(2) <= 0)   %Se entrambe le componenti sono negative/nulle
        newV = currentV;                    %La nuova velocità rimane uguale alla precedente
    end

    %Controllo del valore massimo ammissibile per la velocità
    if (newV(1) > 4)                        %Se componente lungo x è maggiore o uguale a 5
        newV(1) = 4;
    elseif (newV(2) > 4)                    %Se componente lunngo y è maggiore o uguale a 5
        newV(2) = 4;
    end

    %Velocità finale dopo i controlli sulle singole componenti
    finalV = newV;
end