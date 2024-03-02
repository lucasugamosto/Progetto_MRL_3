function [nextState, reward, v] = updateState(state, v, track, initialState, finalState)
    %Funzione che riceve in ingresso:
        %Lo stato corrente in cui si trova l'auto (state);
        %Il vettore delle componenti di velocità lungo x ed y (v);
        %Le informazioni sul tracciato.
    %In uscita viene restituito il nuovo stato in cui si posiziona l'auto,
    %la ricompensa ottenuta passando al nuovo stato e la velocità dell'auto   
    initialS = length(initialState);             %Numero degli stati di partenza
    finalS = length(finalState);                 %Numero degli stati di arrivo
    
    %Ricavare gli indici di riga e di colonna dello stato corrente
    [numRow, numCol] = ind2sub([32 17], state);

    %Calcolo dello stato successivo e successivo controllo sul fatto che
    %questo sia o meno uno stato percorribile
    next_numRow = numRow - v(1);                 %Il segno "-" è dovuto al fatto che l'indice di riga cresce verso il basso
    next_numCol = numCol + v(2);                 %Il segno "+" è dovuto al fatto che l'indice di colonna cresce verso destra

    if (next_numRow < 1 || next_numCol < 1 || next_numRow >32 || next_numCol > 17)
        %Condizione in cui la transizione porta l'auto fuori dalla matrice,
        %quindi non sono operazioni possibili

        %Riposizionamento casuale dell'auto in uno degli stati di partenza, 
        %assegnazione negativa della ricompensa e reset della velocità
        nextState = initialState(randi(initialS));
        % nextState = initialState(1);
        reward = -1;
        v = [0,0];
    else
        %L'auto si sposta all'interno della matrice degli stati
        nextState = sub2ind([32 17], next_numRow, next_numCol);
        
        %Controllare che il nuovo stato in cui si trova l'auto faccia parte
        %della pista (valore associato è 1) oppure si trovi fuori dalla
        %pista (valore associato è 0)
        if (track(nextState) == 0)               %Auto fuori dalla pista
            nextState = initialState(randi(initialS));
            % nextState = initialState(1);
            reward = -1;
            v = [0,0];
        else                                     %Auto all'interno della pista
            %Controllare se il nuovo stato sia uno stato finale oppure
            %transitorio
            if (nextState >= finalState(1) && nextState <= finalState(finalS))
                %Si è raggiunta la linea di arrivo
                reward = 0;
                v = [0,0];
            else
                %Si trasla su uno stato transitorio
                reward = -1;
            end
        end
    end