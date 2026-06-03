# Frutta S.r.l. — Client

Thin client a riga di comando per la base di dati **Frutta S.r.l.**, sviluppato nell'ambito del progetto di Basi di Dati A.A. 2025/2026.

L'applicazione consente a due tipologie di utenti — operatore vendite e magazziniere — di interagire con il DB tramite le stored procedure definite nello schema.

---

## Requisiti

- Java 17+
- MariaDB 10.x / MySQL 8.x in esecuzione su `localhost:3306`
- Driver MySQL Connector/J (JAR incluso in `libs/`)

---

## Configurazione

### 1. Inizializzare il database

Eseguire lo script `src/schema.sql` sul server MariaDB/MySQL. Lo script crea lo schema `frutta_srl`, le tabelle, i trigger, gli eventi, le stored procedure, gli utenti applicativi e popola i dati di esempio.

```sql
SOURCE src/schema.sql;
```

### 2. Verificare `resources/db.properties`

Il file contiene le credenziali degli utenti applicativi. Assicurarsi che corrispondano a quelle definite nei `CREATE USER` dello schema:

```properties
CONNECTION_URL=jdbc:mariadb://localhost:3306/frutta_srl
LOGIN_USER=login
LOGIN_PASS=login
OPERATORE_VENDITE_USER=operatore_vendite
OPERATORE_VENDITE_PASS=operatore_vendite
MAGAZZINIERE_USER=magazziniere
MAGAZZINIERE_PASS=magazziniere
```

### 3. Aggiungere il driver JDBC

Verificare che `libs/mysql-connector-j-8.0.31.jar` sia presente e incluso nel classpath del progetto.

---

## Avvio

Eseguire `Main.java` da IntelliJ oppure da riga di comando:

```bash
java -cp "out/production/...:libs/mysql-connector-j-8.0.31.jar" it.basi.fruttasrl.Main
```

---

## Credenziali di esempio

| Username   | Password    | Ruolo              |
|------------|-------------|--------------------|
| `m.rossi`  | `password123` | Operatore vendite |
| `g.bianchi`| `password123` | Magazziniere      |

---

## Operazioni disponibili

### Operatore vendite

**Inserisci ordine cliente** — corrisponde all'operazione S della relazione. Guida l'utente attraverso la creazione dell'ordine e l'inserimento dei prodotti in sequenza. Se nessun prodotto viene inserito con successo (es. quantità insufficiente in magazzino), l'ordine viene annullato automaticamente.

Internamente esegue in sequenza le stored procedure `CreaOrdine` e `InserisciProdottoOrdine`.

### Magazziniere

**Report scadenze** — corrisponde all'operazione M1. Mostra i prodotti in scadenza nei prossimi 7 giorni, raggruppati per giorno e ordinati per data.

**Registra prodotto in magazzino** — corrisponde all'operazione M2. Registra l'arrivo di un lotto. Se esiste già un record con lo stesso prodotto e data di arrivo, la quantità viene sommata a quella esistente.

---

## Struttura del progetto

```
src/
└── it/basi/fruttasrl/
    ├── Main.java
    ├── controller/         # Logica di routing e orchestrazione
    ├── dao/                # Accesso al DB tramite stored procedure
    ├── model/
    │   ├── domain/         # Role, UserCredentials
    │   └── dto/            # Record di input/output per i DAO
    ├── view/               # Interazione con l'utente via terminale
    └── exception/          # AppException, DAOException
resources/
└── db.properties           # Credenziali di connessione
libs/
└── mysql-connector-j-8.0.31.jar
src/
└── schema.sql              # Script completo di istanziazione del DB
```

---

## Note sulla sicurezza

Tutti gli accessi al DB avvengono tramite utenti applicativi con privilegi minimi (`EXECUTE` sulle sole stored procedure di competenza). La connessione viene riaperta con l'utente corretto dopo il login, in base al ruolo autenticato. Tutte le query parametrizzate usano `PreparedStatement` per prevenire SQL injection.