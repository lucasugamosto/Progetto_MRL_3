%Luca Sugamosto, matricola 0324613
%Mattia Quadrini, matricola 0334381

%Traccia del progetto:

%Si consideri di guidare un'auto da corsa lungo un percorso come quello in
%figura.

%Si vuole andare il più veloce possibile, ma non così veloce da correre
%fuori pista. Nella nostra pista semplificata, l'auto si trova in una serie
%discreta di posizioni della griglia, le celle nel diagramma.

%Anche la velocità è discreta, un numero di celle della griglia sono
%percorse orizzontalmente e verticalmente per passo temporale. Le 'azioni'
%sono variare le componenti di velocità. Ognuna può essere variata di
%+1, -1, 0 in ogni passo.

%Entrambe le componenti di velocità sono ristrette ad essere non negative e
%minori di 5, e loro non possono essere entrambe 0 eccetto alla linea di
%partenza.

%Ogni episodio inizia in uno degli stati iniziali selezionati casualmente
%con entrambe le componenti di velocità nulle e finisce quando la macchina
%attraversa la linea di arrivo. Se l'auto colpisce il limite della pista,
%viene riportata in una posizione casuale sulla linea di partenza, entrambe
%le componenti della velocità vengono ridotte a zero e l'episodio continua.

%I rewards sono -1 per ogni passo temporale finchè l'auto non attraversa la
%linea di arrivo.

%Prima di aggiornare la posizione dell'auto in ogni passo temporale,
%controllare se il percorso proiettato dall'auto intereseca il confine del
%binario. Se taglia il traguardo, l'episodio finisce; se interseca un altro
%punto, si considera che l'auto abbia toccato il confine della pista e
%viene rimandata alla linea di partenza.

%Applicare un metodo di controllo Monte Carlo a questa attività per
%calcolare la politica ottima da ogni stato iniziale.
%--------------------------------------------------------------------------
clear
close all
clc

%Numero di stati del processo
S = 17*32;        %17 colonne e 32 righe

%Inizializzazione della matrice che rappresenta la pista da percorrere
track = zeros(32,17);      

%Le caselle con valore 1 rappresentano quelle percorribili mentre quelle 
%con valore 0 rappresentano zone non percorribili.
%Usando i seguenti indici si considera lo stato i-esimo e non le coordinate
%dello stato i-esimo
for s = 5:14 
    track(s) = 1;
end
for s = 36:54
    track(s) = 1;
end
for s = 66:93
    track(s) = 1;
end
for s = 97:295
    track(s) = 1;
end
%Usando i seguenti indici si considerano le coordinate dello stato i-esimo
for j = 11:17
    for i = 1:6
        track(i,j) = 1;
    end
end

%Inizializzazione degli stati di partenza e degli stati di arrivo
initialState = [128; 160; 192; 224; 256; 288];
finalState = [513; 514; 515; 516; 517; 518];

save raceTrack.mat  S track initialState finalState