# Game Design Document + Prompt di sviluppo — Progetto Godot

> **Stato:** specifica iniziale per MVP  
> **Motore:** Godot 4.x  
> **Linguaggio:** GDScript  
> **Genere:** puzzle / exploration roguelite investigativo  
> **Visuale:** top-down 2D, stanze collegate da porte  
> **Priorità:** realizzare prima un prototipo piccolo, completo e giocabile; rimandare la generazione procedurale alla fase successiva.

---

## 1. Prompt principale per un assistente di programmazione

Agisci come un **programmatore esperto di Godot 4 e game designer tecnico**, con esperienza nella realizzazione di giochi 2D top-down e architetture semplici da mantenere.

Aiutami a sviluppare in modo incrementale il gioco descritto in questo documento. Il progetto deve essere accessibile a una persona con poca esperienza di programmazione.

### Regole di lavoro

1. **Usa Godot 4.x e GDScript**, evitando dipendenze esterne e plugin non necessari.
2. Procedi per piccoli passi verificabili. Non implementare l'intero gioco in un'unica risposta.
3. Prima di scrivere codice, spiega brevemente quale sistema stiamo realizzando e come si integra con quelli esistenti.
4. Fornisci codice completo per ogni script nuovo o modificato, indicando il percorso del file e il nodo a cui collegarlo.
5. Quando descrivi una scena, specifica la gerarchia dei nodi, i tipi di nodo, i segnali da collegare e le impostazioni rilevanti nell'Inspector.
6. Preferisci soluzioni semplici, leggibili e idiomatiche per Godot 4. Evita astrazioni premature, sistemi generici eccessivamente complessi e duplicazione della logica.
7. Non inventare API di Godot. Usa sintassi compatibile con Godot 4.x.
8. Dopo ogni fase, fornisci una breve checklist di test manuali e i risultati attesi.
9. Se una decisione non è specificata, scegli la soluzione più semplice che rispetta il design e segnala l'assunzione. Fai pure domande se qualcosa non è chiaro. Meglio una domanda in più che un errore.
10. Non passare alla fase successiva finché la fase corrente non è ragionevolmente testabile.
11. Mantieni separati lo stato temporaneo della run e la progressione persistente della partita.
12. Non implementare ancora generazione procedurale, combattimento, dialoghi, salvataggi su disco o sistemi non richiesti per l'MVP.
13. Se modifichi codice già fornito, spiega cosa cambia e restituisci il contenuto completo dei file modificati.
14. Segnala gli errori di progettazione o le dipendenze circolari prima che diventino difficili da correggere.

### Prima risposta richiesta

Inizia proponendo:
- una struttura minima delle cartelle del progetto;
- l'architettura delle scene e degli autoload necessari;
- un piano di sviluppo ordinato in fasi;
- le decisioni tecniche da fissare prima di scrivere codice.

**Non generare subito tutto il codice.** Il primo obiettivo è costruire una base funzionante e testabile.

---

## 2. Visione del gioco

Il giocatore interpreta una spia che è stata catturata prima di raggiungere un laboratorio segreto nel quale doveva svolgere un'indagine.

Si risveglia nella cella del laboratorio e cerca di fuggire. Ha un tempo limitato prima che le guardie arrivino e lo catturino nuovamente. Quando viene catturato, viene riportato nella cella e inizia una nuova run.

Il laboratorio rimane identico durante tutte le run della stessa partita. Il giocatore conserva tutte le informazioni scoperte, ma può salvare solo un numero limitato di **oggetti fisici**. Gli oggetti non salvati vengono persi o confiscati.

L'obiettivo principale è **uscire dal laboratorio**. Completare l'indagine per cui la spia era stata inviata è un obiettivo secondario e facoltativo.

### Principio centrale

> **Puoi ricordare tutto. Ma non puoi portare tutto con te.**

Il gioco è incentrato su esplorazione, pianificazione, gestione degli oggetti e apprendimento della struttura del livello. Non prevede combattimento.

---

## 3. Pilastri di design

1. **Conoscenza persistente:** ogni informazione scoperta durante una partita resta disponibile nelle run successive.
2. **Oggetti limitati:** dopo una cattura si sceglie un numero limitato di oggetti fisici da conservare.
3. **Mondo statico durante la partita:** stanze, collegamenti e collocazione degli oggetti non cambiano tra le run.
4. **Timer leggibile:** il tempo limita quanto si può esplorare in una singola fuga.
5. **Nessun combattimento:** il giocatore risolve problemi esplorando, usando oggetti e trovando percorsi.
6. **Fuga prima dell'indagine:** l'uscita è l'obiettivo principale; l'indagine è facoltativa.
7. **Progressione attraverso la comprensione:** le run successive diventano più efficaci grazie alla conoscenza acquisita, non soltanto grazie a potenziamenti permanenti.

---

## 4. Piattaforma e presentazione

- Motore: **Godot 4.x**.
- Linguaggio: **GDScript**.
- Genere: puzzle / exploration roguelite investigativo.
- Prospettiva: top-down 2D.
- Struttura: stanze separate, collegate da porte; ispirazione strutturale a *The Binding of Isaac*, ma senza arene di combattimento.
- Grafica iniziale: placeholder semplici (forme, tile, icone e testo). La grafica definitiva non è necessaria per verificare il gameplay.
- Interfaccia: timer, inventario, indicazione di interazione e schermata di scelta degli oggetti dopo la cattura.
- Audio: non necessario per il primo prototipo.

Il giocatore deve poter attraversare le stanze senza che le porte si chiudano automaticamente e senza dover eliminare tutti i personaggi presenti.

---

## 5. Loop di gioco

1. La run inizia nella cella.
2. Il timer parte.
3. Il giocatore esplora le stanze e raccoglie oggetti.
4. Può esaminare elementi ambientali e scoprire informazioni.
5. Usa gli oggetti per aprire accessi o superare ostacoli.
6. Se raggiunge l'uscita, la partita termina con una fuga riuscita.
7. Se il timer raggiunge zero prima della fuga:
   - la run termina con una cattura;
   - gli oggetti raccolti vengono mostrati al giocatore;
   - il giocatore sceglie quali conservare, entro il limite previsto;
   - tutte le informazioni scoperte restano registrate;
   - lo stato temporaneo viene resettato;
   - inizia una nuova run dalla cella.

La cattura non deve essere presentata come morte. È un evento narrativo di recupero da parte delle guardie.

### Distinzione fondamentale

- **Run:** un singolo tentativo di fuga.
- **Partita / sessione:** l'insieme delle run che condividono la stessa mappa, le stesse collocazioni e le stesse scoperte.
- **New Game:** avvia una nuova partita. Nella MVP questa funzione può semplicemente resettare la partita; in una versione futura genererà un nuovo laboratorio.

---

## 6. Regole di persistenza

### 6.1 Informazioni e memorie

- Le informazioni scoperte sono persistenti e non occupano slot.
- Una volta scoperta un'informazione, resta consultabile per il resto della partita.
- Le informazioni possono includere codici, procedure, dettagli della missione e indizi investigativi.
- Le informazioni non devono essere obbligatoriamente equipaggiate o selezionate dopo una cattura.
- Le informazioni vengono cancellate quando si avvia una nuova partita.
- Nell'MVP possono essere mostrate in un semplice diario consultabile.

### 6.2 Oggetti fisici

- Gli oggetti hanno un identificatore univoco e proprietà definite.
- Il giocatore può raccogliere oggetti durante una run.
- Il numero di oggetti conservabili dopo una cattura è limitato. **Valore iniziale suggerito: 1 slot**, da rendere configurabile.
- Dopo la cattura, il giocatore seleziona gli oggetti da conservare tra quelli in suo possesso.
- Gli oggetti selezionati sono disponibili all'inizio della run successiva.
- Gli oggetti non selezionati vengono persi/confiscati.
- Non si possono conservare più oggetti del limite consentito.
- Gli oggetti portati da una run precedente non devono essere duplicati quando il giocatore li raccoglie o li usa.
- Un oggetto consumabile, se introdotto in futuro, deve avere regole esplicite su consumo e persistenza.

### 6.3 Stato temporaneo della run

Viene azzerato a ogni nuova run:
- timer;
- posizione del giocatore;
- oggetti raccolti durante la run, fatta eccezione per quelli persistenti selezionati;
- porte o dispositivi temporaneamente attivati, se previsti;
- eventi temporanei;
- stato di allarme temporaneo, se aggiunto in futuro.

### 6.4 Stato persistente della partita

Rimane invariato tra le run:
- informazioni scoperte;
- oggetti selezionati per la conservazione;
- eventuali obiettivi investigativi completati;
- stato di completamento della partita, se necessario.

Nella MVP non è richiesto salvare su disco e riprendere la partita dopo aver chiuso il gioco. La persistenza è soltanto in memoria durante la sessione di gioco.

---

## 7. Timer

- Durata iniziale suggerita: **5 minuti**, configurabile.
- Il timer parte all'inizio della run.
- Il timer diminuisce in tempo reale.
- Quando raggiunge zero, la cattura viene attivata una sola volta.
- Durante la schermata di cattura e la selezione degli oggetti, il timer è fermo.
- Il timer deve essere visibile e leggibile nell'interfaccia.
- Il timer non deve essere azzerato da una transizione tra stanze.
- Il giocatore può raggiungere l'uscita prima dello scadere del tempo.
- Gli eventi temporali sono una funzionalità futura, non necessaria per la MVP.

### Possibile estensione futura

Un sistema di eventi può attivare o disattivare elementi in base al tempo residuo, per esempio:
- scatta un allarme;
- una porta viene bloccata;
- uno scienziato lascia una stanza;
- si apre una finestra temporanea per attraversare un corridoio.

Questi eventi devono essere opzionali e non devono compromettere la leggibilità del livello.

---

## 8. Movimento, interazione e personaggi

### Giocatore

Per la MVP deve poter:
- muoversi in quattro o otto direzioni;
- collidere con muri e ostacoli solidi;
- attraversare le porte attive;
- raccogliere oggetti tramite un'interazione semplice;
- esaminare alcuni elementi ambientali;
- usare un oggetto su un elemento compatibile, se richiesto dal puzzle.

Non implementare combattimento, armi, gadget iniziali o abilità speciali. La spia utilizza esclusivamente oggetti trovati nel laboratorio.

### Scienziati

- Sono personaggi decorativi.
- Non sono nemici.
- Non hanno dialoghi.
- Non possono essere interrogati o attaccati.
- Possono essere rappresentati con sprite placeholder statici.
- Non devono bloccare il percorso del giocatore nella MVP, a meno che un test specifico non richieda un ostacolo solido.

### Interazioni

Le interazioni devono essere coerenti e semplici. Per esempio:
- avvicinarsi a un oggetto e premere un tasto per raccoglierlo;
- avvicinarsi a un terminale e premere un tasto per leggere un'informazione;
- usare un oggetto compatibile su una porta o un dispositivo.

Mostrare un'indicazione contestuale quando un'interazione è disponibile, se possibile.

---

## 9. Mappa della MVP

La prima versione deve avere una mappa fissa e piccola. Non implementare ancora la generazione procedurale.

Proposta di mappa logica iniziale:

```text
             [ARCHIVIO]
                  |
[CELLA] — [CORRIDOIO] — [LABORATORIO]
                  |              |
             [DEPOSITO] — [USCITA]
```

Questa è una bozza concettuale, non una disposizione definitiva. La mappa deve essere verificata rispetto ai requisiti del puzzle prima di implementarla.

### Requisiti della mappa

- La cella è il punto di partenza di ogni run.
- L'uscita è raggiungibile solo dopo aver superato almeno un ostacolo che richiede un oggetto.
- Devono esserci almeno un percorso esplorativo e una stanza opzionale con un indizio investigativo.
- La mappa non cambia durante una partita.
- Porte, oggetti e informazioni sono posizionati in modo deterministico.
- La transizione tra stanze deve mantenere il timer attivo.
- Il giocatore deve poter tornare indietro tra le stanze già accessibili.
- Non usare generazione casuale per stanze, collegamenti o oggetti nella MVP.

La mappa esatta e la sequenza degli ostacoli vanno definite prima del level scripting, così da evitare chiavi irraggiungibili o dipendenze circolari.

---

## 10. Contenuti minimi della MVP

Usare placeholder grafici. Il numero di elementi deve rimanere ridotto.

### Stanze

Circa 6 stanze:
1. Cella iniziale.
2. Corridoio principale.
3. Archivio.
4. Laboratorio.
5. Deposito o locale tecnico.
6. Uscita.

### Oggetti

Includere pochi oggetti con funzioni chiare, per esempio:
- cacciavite;
- tessera di sicurezza;
- chiave o strumento per un accesso secondario;
- documento investigativo.

Non è obbligatorio utilizzare tutti questi oggetti se la soluzione più semplice richiede meno elementi.

### Informazioni

Almeno:
- un'informazione necessaria o utile per orientare il giocatore;
- un indizio investigativo facoltativo;
- una schermata o pannello che consenta di consultare le informazioni scoperte.

### Ostacoli

- almeno una porta o un dispositivo che richieda un oggetto;
- almeno un percorso o contenuto opzionale;
- un'uscita che concluda la run con successo.

### Cattura

Quando il timer scade:
1. bloccare il movimento e le interazioni;
2. mostrare una schermata di cattura;
3. elencare gli oggetti che il giocatore può conservare;
4. consentire la selezione fino al limite;
5. confermare la scelta;
6. resettare lo stato temporaneo;
7. ricominciare dalla cella con il timer ripristinato.

### Fuga

Quando il giocatore raggiunge l'uscita e soddisfa le condizioni richieste:
- fermare il timer;
- bloccare il movimento;
- mostrare una schermata di fuga riuscita;
- indicare se l'indagine è incompleta o completata.

Non serve una sequenza cinematografica nella MVP.

---

## 11. Requisiti di gameplay e bilanciamento

Il prototipo deve dimostrare che:
- una singola run può non essere sufficiente per fuggire;
- le informazioni raccolte rendono le run successive più efficienti;
- conservare un oggetto ha un costo opportunità;
- il giocatore non deve ripetere inutilmente lunghe sezioni già comprese;
- la fuga resta l'obiettivo primario;
- l'indagine opzionale premia l'esplorazione senza bloccare il completamento principale.

Evitare di rendere il primo tentativo impossibile soltanto per forzare la ripetizione. È preferibile che il giocatore possa fallire perché non conosce ancora il percorso o non ha l'oggetto adatto, ma che possa migliorare grazie alle scoperte fatte.

Se una porta richiede un oggetto che il giocatore non può ancora ottenere, deve esistere una spiegazione leggibile e una possibilità concreta di recuperare l'oggetto in una run successiva.

---

## 12. Architettura tecnica suggerita

Non è necessario adottare esattamente questa struttura se Godot offre una soluzione più semplice, ma mantenere le responsabilità separate.

### Scene indicative

```text
res://
├── project.godot
├── scenes/
│   ├── main/
│   │   └── Main.tscn
│   ├── player/
│   │   └── Player.tscn
│   ├── rooms/
│   │   ├── RoomBase.tscn
│   │   ├── Cell.tscn
│   │   ├── Corridor.tscn
│   │   ├── Archive.tscn
│   │   ├── Laboratory.tscn
│   │   ├── Storage.tscn
│   │   └── ExitRoom.tscn
│   ├── objects/
│   │   └── Pickup.tscn
│   └── ui/
│       ├── HUD.tscn
│       ├── MemoryLog.tscn
│       ├── CaptureScreen.tscn
│       └── EscapeScreen.tscn
├── scripts/
│   ├── managers/
│   │   ├── GameManager.gd
│   │   └── RunManager.gd
│   ├── player/
│   │   └── Player.gd
│   ├── rooms/
│   │   └── Door.gd
│   ├── objects/
│   │   └── Pickup.gd
│   └── ui/
│       └── HUD.gd
├── data/
│   └── items/
└── assets/
    ├── sprites/
    ├── fonts/
    └── audio/
```

### Responsabilità

- **GameManager**: stato persistente della partita, memorie scoperte, oggetti conservati e stato dell'indagine.
- **RunManager**: inizio/fine run, timer, oggetti temporanei e transizione dopo la cattura.
- **Player**: movimento, collisioni e richieste di interazione.
- **Pickup**: rappresenta un oggetto raccoglibile e comunica il proprio identificatore.
- **Door / Interactable**: verifica i requisiti di accesso o utilizzo.
- **HUD**: visualizza timer, oggetti e informazioni.
- **CaptureScreen**: consente di selezionare gli oggetti da conservare.
- **EscapeScreen**: mostra il risultato della fuga.

Per un progetto piccolo è possibile unire alcune responsabilità, purché lo stato persistente e quello temporaneo restino distinti. Evitare di creare un autoload per ogni sistema senza una necessità concreta.

### Stato suggerito

**Stato della run**
- tempo residuo;
- stanza corrente e posizione del giocatore;
- oggetti raccolti nella run;
- stato temporaneo di porte e dispositivi.

**Stato persistente della partita**
- insieme degli ID delle informazioni scoperte;
- lista degli ID degli oggetti conservati;
- obiettivi investigativi completati;
- stato di completamento della partita.

Preferire ID stabili (per esempio `security_badge`, `screwdriver`, `lab_report`) rispetto a confronti basati sul testo visualizzato.

---

## 13. Criteri di accettazione della MVP

La MVP può considerarsi pronta quando tutti i punti seguenti funzionano:

- [ ] Il progetto si avvia senza errori in Godot 4.x.
- [ ] Il giocatore si muove e collide correttamente con muri e ostacoli.
- [ ] È possibile passare tra le stanze collegate.
- [ ] Il timer continua a scorrere durante le transizioni.
- [ ] Il giocatore può raccogliere oggetti.
- [ ] Le informazioni scoperte vengono aggiunte al diario.
- [ ] Le informazioni rimangono disponibili dopo la cattura.
- [ ] Il timer a zero attiva la cattura una sola volta.
- [ ] Il giocatore può scegliere gli oggetti da conservare entro il limite.
- [ ] Gli oggetti non selezionati vengono persi.
- [ ] Gli oggetti selezionati sono disponibili nella run successiva.
- [ ] La nuova run riparte dalla cella con il timer ripristinato.
- [ ] La mappa e le collocazioni non cambiano tra le run.
- [ ] Un oggetto può sbloccare un accesso o un dispositivo.
- [ ] Raggiungere l'uscita conclude la run con successo.
- [ ] L'indagine può essere completata oppure lasciata incompleta.
- [ ] Il comando New Game resetta lo stato della partita.
- [ ] Non ci sono combattimento, dialoghi o gadget iniziali.

---

## 14. Piano di sviluppo consigliato

### Fase 1 — Progetto vuoto funzionante
- Creare il progetto Godot.
- Impostare risoluzione e input.
- Creare una scena principale.
- Verificare che il progetto si avvii.

### Fase 2 — Movimento
- Creare il giocatore.
- Implementare movimento top-down e collisioni.
- Usare grafica placeholder.
- Testare il movimento in una stanza.

### Fase 3 — Stanze e porte
- Creare due stanze collegate.
- Implementare transizioni e posizionamento corretto del giocatore.
- Verificare che non possa attraversare muri o porte bloccate.

### Fase 4 — Oggetti e interazioni
- Implementare oggetti raccoglibili con ID stabili.
- Implementare una porta che richiede un oggetto.
- Aggiungere un'interfaccia essenziale per l'inventario.

### Fase 5 — Timer e cattura
- Implementare timer globale della run.
- Fermare la run allo scadere.
- Mostrare la schermata di cattura.

### Fase 6 — Persistenza tra run
- Implementare selezione degli oggetti da conservare.
- Mantenere tutte le informazioni scoperte.
- Resettare soltanto lo stato temporaneo.
- Ripartire dalla cella.

### Fase 7 — Mappa MVP e fuga
- Costruire le 6 stanze.
- Sistemare gli oggetti e le dipendenze.
- Implementare l'uscita.
- Testare almeno due run consecutive.

### Fase 8 — Indagine opzionale e rifinitura
- Aggiungere indizi e diario.
- Distinguere fuga con indagine incompleta e completa.
- Migliorare feedback UI, controlli e chiarezza degli obiettivi.
- Correggere bug e problemi di bilanciamento.

### Fase futura — Nuove partite procedurali
Non iniziare questa fase finché la MVP fissa non è giocabile e divertente.

---

## 15. Specifiche per la versione futura

Queste caratteristiche sono fuori dall'MVP, ma l'architettura non dovrebbe renderle inutilmente difficili.

### Generazione procedurale tra partite

- Ogni New Game genera un nuovo laboratorio.
- Durante una singola partita, tutte le run riutilizzano la stessa mappa generata.
- La generazione usa stanze prefabbricate e regole di collegamento, non necessariamente mappe completamente casuali.
- Gli oggetti vengono collocati in posizioni differenti tra partite.
- Porte, chiavi e oggetti devono rispettare le dipendenze di accessibilità.
- Deve sempre esistere almeno un percorso valido verso l'uscita.
- Gli oggetti necessari non devono essere collocati dietro gli ostacoli che richiedono quegli stessi oggetti.
- La generazione deve poter essere riprodotta tramite un seed, utile per debug e test.
- Le informazioni e gli oggetti della partita devono essere coerenti con la configurazione generata.

### Eventi temporali

Possibili eventi attivati in base al tempo residuo:
- allarme di sicurezza;
- porte che vengono bloccate;
- cambiamenti ambientali;
- aperture temporanee di percorsi.

Non sono necessari per il primo prototipo.

### Altre estensioni possibili

- salvataggio della partita su disco;
- più tipi di oggetti e ostacoli;
- più indagini o finali;
- animazioni e audio;
- localizzazione;
- statistiche di run.

---

## 16. Decisioni ancora da verificare

Usare questi valori come default provvisori, senza bloccare il prototipo:

| Decisione | Default MVP |
|---|---|
| Versione Godot | Godot 4.x stabile |
| Visuale | Top-down 2D |
| Durata run | 5 minuti |
| Slot per oggetti conservati | 1 |
| Memorie persistenti | Illimitate |
| Mappa | Fissa per tutta la partita |
| Numero di stanze | Circa 6 |
| Combattimento | Assente |
| NPC | Scienziati decorativi |
| Dialoghi | Assenti |
| Oggetti iniziali della spia | Nessuno |
| Generazione procedurale | Solo fase futura |
| Salvataggio su disco | Non richiesto per MVP |
| Obiettivo principale | Fuga |
| Obiettivo secondario | Completare l'indagine |

Questi numeri sono parametri iniziali da provare, non vincoli definitivi.

---

## 17. Istruzione per iniziare il lavoro

Leggi l'intero documento e poi procedi soltanto con la **Fase 1**.

Prima di fornire codice:
1. riassumi l'architettura minima;
2. indica quali scene e script verranno creati nella Fase 1;
3. elenca i passaggi da eseguire nell'editor Godot;
4. fornisci una checklist per verificare che il progetto funzioni.

Non implementare sistemi delle fasi successive in anticipo. L'obiettivo è arrivare a un prototipo completo per piccoli incrementi, mantenendo ogni passaggio comprensibile e testabile.
