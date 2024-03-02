%ON-POLICY EVERY-VISIT MONTE CARLO CONTROL

clear
close all
clc

load raceTrack.mat                     %Caricamento delle variabili  necessarie all'algoritmo

numEpisodes = 5*(10^5);                %Numeri di episodi totali
finalS = length(finalState);           %Numero di stati terminali totali
initialS = length(initialState);       %Numeto di stati iniziali totali

%Parametro che garantisce l'esplorazione delle azioni in ogni iterazione.
%All'aumentare delle iterazioni tale parametro deve decrescere per
%garantire che sia usata la policy ottimale e sempre meno azioni vengano
%prese casualmente
epsilon = 0.8;
decrease = 0.00015;                    %Valore sottratto ad epsilon

gamma = 0.9;                           %Fattore di scarto (indica a quale reward dare maggiore importanza)
alpha = 0.01;                           %Passo di aggiornamento costante

%Inizializzazione della matrice che contiene tutte le azione possibili
actionList = [[0,1];[1,0];[1,1];[0,0];[-1,0];[0,-1];[-1,-1];[-1,1];[1,-1]];

A = length(actionList);                %Numero di azioni totali

%FASE DI INIZIALIZZAZIONE DELL'ALGORITMO
Q = zeros(S,A);                        %Stima della funzione qualità
N = zeros(S,A);                        %Occorrenze per ogni coppia stato-azione
pi = randi(A,[S 1]);                   %Policy iniziale randomica

%L'azione associata agli stati terminali è quella di non fare nulla quindi
%sia la componente x sia la componente y deve essere nulla
for i = 1:finalS
    pi(finalState(i)) = 4;             %"4" è l'indice dell'azione [0, 0]
end

counters = [];                         %Contiene tutti i contatori associati ad ogni singolo episodio
bestPath = [];                         %Contiene tutti gli stati percorsi dall'auto usando la policy ottimale
bestActions = [];                      %Vettore delle azioni prese nel percorso migliore
valBestPath = inf;                     %Indica il numero di stati percorsi dall'auto usando la policy ottimale

%%

%FASE DI AGGIORNAMENTO DELL'ALGORITMO
for i = 1:numEpisodes
    fprintf("n° episodio esaminato:");
    disp(i);
    fprintf("Epsilon utilizzato:");
    disp(epsilon);
    %Scelta casuale dello stato da cui partire
    S0 = initialState(randi(initialS));          %Scelta casuale dello stato di partenza
    %Scelta fissa dello stato da cui partire (per analizzare se partendo da
    %ogni stato iniziale si arriva comunque a quello finale)
    % S0 = initialState(1);

    firstAction = 1;                             %Variabile posta ad 1 ogni volta che inizia un nuovo episodio 
    v = [0, 0];                                  %Componenti della velocità inizialmente nulle ad ogni nuovo episodio

    %Inizializzazione dei vettori che tengono traccia degli stati, delle
    %azioni e dei rewards relativi all'episodio corrente
    states = S0;                                 %Contiene già il primo stato che si visita
    currentState = S0;                           %Stato in cui si trova l'auto
    actions = [];
    rewards = [];
    
    reward = -1;                                 %Valore della ricompensa istantanea
    counter = 1;                                 %Numero di iterazioni necessarie per arrivare nello stato terminale

    %Generazione dell'episodio a partire dalla coppia (S0, A0)
    while (reward == -1)
        if (firstAction == 1)
            %Scelta dell'azione di partenza A(0)
            a = randi(A);                        %Indice dell'azione da prendere
            action = actionList(a,:);            %Azione vera e propria da prendere
            
            %Si assegna alla variabile "firstAction" valore 0 così le
            %successive azioni sono prese seguendo la policy calcolata
            firstAction = 0;
        else
            %Scelta delle azioni A(t) successive (algoritmo Eps-Greedy)
            if (rand(1) < epsilon)
                %Azione scelta casualmente
                a = randi(A);                    %Indice dell'azione da prendere
                action = actionList(a,:);        %Azione vera e propria da prendere
            else
                %Azione scelta seguendo la policy
                a = pi(currentState);            %indice dell'azione da prendere
                action = actionList(a,:);        %Azione vera e propria da prendere
            end

        end

        %Controllo dei valori di velocità da passare in ingresso alla
        %funzione "updateState", questi devono essere: non negativi, minori
        %di 5 e non possono essere entrambi nulli (negli stati intermedi)
        newV = v + action;                       %Nuovo vettore delle velocità lungo x ed y
        
        %Velocità da passare in ingresso alla funzione "updateState"
        v = speedControl(v, newV);

        %Calcolo del nuovo stato in cui si colloca l'auto e della nuova
        %ricompensa ottenuta
        %La velocità "v" in uscita è diversa dalla velocità "v" in ingresso
        %se e solo se si hanno delle condizioni limite, cioè si esce dalla
        %mappa, si esce dal tracciato o si arriva a destinazione. In ognuno
        %di questi casi torna un vettore di velocità nullo.
        [nextState, reward, v] = updateState(currentState, v, track, initialState, finalState);

        %Aggiunta dei nuovi valori nelle liste associate agli stati,
        %azioni, rewards
        states = horzcat(states, nextState);
        rewards = horzcat(rewards, reward);
        actions = horzcat(actions, a);

        %Aggiornamento delle variabili per l'iterazione del loop successiva
        currentState = nextState;
        counter = counter + 1;
    end
    %GENERAZIONE DELL'EPISODIO i-ESIMO TERMINATO

    %Aggiunta dei nuovi valori nella lista associata ai contatori delle
    %iterazioni per singolo episodio
    counters = horzcat(counters,counter);

    if (mod(i,100) == 0 && epsilon > 0.05)
        epsilon = epsilon - decrease;            %Aggiornamento del parametro Epsilon (minore esplorazione, maggiore sfruttamento)
    end

    %Se l'episodio generato in questa iterazione è migliore di tutti gli
    %altri generati fino ad ora allora lo salvo come "miglior percorso"
    if (states(end) >= finalState(1) && states(end) <= finalState(finalS) && counter < valBestPath)
        bestPath = states;                       %Aggiornamento del percorso migliore
        valBestPath = counter;                   %Aggiornamento del numero di stati del percorso migliore
        bestActions = actions;                   %Aggiornamento delle azioni prese nel percorso migliore
    end
    
    %AGGIORNAMENTO DELLA POLICY
    %Una volta generato l'episodio si va a calcolare a retroso il ritorno
    %atteso G, il quale permette di calcolare la funzione qualità e
    %successivamente migliorare la policy
    G = 0;                                       %Ritorno atteso
    for t = length(rewards):-1:1                 %Scorrimento dell'indice all'indietro
        G = rewards(t) + (gamma * G);
        %Il passo di aggiornamento nella seguente formula è COSTANTE
        Q(states(t), actions(t)) = Q(states(t), actions(t)) + (alpha * (G - Q(states(t), actions(t))));     
        
        %Il passo di aggiornamento nella seguente formula è VARIABILE
        %N(states(t), actions(t)) = N(states(t), actions(t)) + 1;
        %Q(states(t), actions(t)) = Q(states(t), actions(t)) + (1 / N(states(t), actions(t))) * (G - Q(states(t), actions(t)))

        %La policy viene aggiornata ad ogni loop
        pi(states(t)) = find(Q(states(t), :) == max(Q(states(t), :)), 1, "first");
    end
end
%%

%RAPPRESENTAZIONE GRAFICA DELLO SPOSTAMENTO DELL'AUTO LUNGO IL TRACCIATO
subplot(2, 1, 1);
for x = 1:17
    for y = 1:32
        rectangle("Position", [x, y, 1, 1], "FaceColor", "white", "EdgeColor", "black", "LineWidth", 1);
    end
end
xlim([0, 18]);                                   %Limiti dell'asse x per una migliore visualizzazione
ylim([0, 33]);                                   %Limiti dell'asse y per una migliore visualizzazione
grid on;
title('Race track - Last Path');

for x = 1:17
    for y = 1:32
        index = sub2ind([32 17], 32-y+1, x);
        if(track(index) == 0)                    %punto della pista non percorribile
            rectangle("Position", [x, y, 1, 1], "FaceColor", "black");
        end
    end
end

%Identificazione nel grafico degli stati iniziali e finali
for ii = 1:initialS
    [y,x] = ind2sub([32 17], initialState(ii));
    rectangle("position", [x, 32-y+1, 1, 1], "FaceColor", "red");
end

for jj = 1:finalS
    [y,x] = ind2sub([32 17], finalState(jj));
    rectangle("Position", [x, 32-y+1, 1, 1], "FaceColor", "green");
end

for ss = 1:length(states)
    [y, x] = ind2sub([32 17], states(ss));       %Calcolo degli indici di riga (y) e di colonna (x) dello stato corrente
    rectangle("Position", [x, 32-y+1, 1, 1], "FaceColor", "blue");
    pause(0.5);
end

subplot(2, 1, 2);
for x = 1:17
    for y = 1:32
        rectangle("Position", [x, y, 1, 1], "FaceColor", "white", "EdgeColor", "black", "LineWidth", 1);
    end
end
xlim([0, 18]);                                   %Limiti dell'asse x per una migliore visualizzazione
ylim([0, 33]);                                   %Limiti dell'asse y per una migliore visualizzazione
grid on;
title('Race track - Best Path');

for x = 1:17
    for y = 1:32
        index = sub2ind([32 17], 32-y+1, x);
        if(track(index) == 0)                    %punto della pista non percorribile
            rectangle("Position", [x, y, 1, 1], "FaceColor", "black");
        end
    end
end

%Identificazione nel grafico degli stati iniziali e finali
for ii = 1:initialS
    [y,x] = ind2sub([32 17], initialState(ii));
    rectangle("position", [x, 32-y+1, 1, 1], "FaceColor", "red");
end

for jj = 1:finalS
    [y,x] = ind2sub([32 17], finalState(jj));
    rectangle("Position", [x, 32-y+1, 1, 1], "FaceColor", "green");
end

for ss2 = 1:length(bestPath)
    [y, x] = ind2sub([32 17], bestPath(ss2));      %Calcolo degli indici di riga (y) e di colonna (x) dello stato corrente
    rectangle("Position", [x, 32-y+1, 1, 1], "FaceColor", "yellow");
    pause(0.5);
end