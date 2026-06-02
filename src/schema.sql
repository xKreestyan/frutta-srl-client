-- =============================================================================
-- Frutta S.r.l. -- Script di istanziazione della base di dati
-- Progetto Basi di Dati A.A. 2025/2026 -- Giovannetti Christian (0322043)
-- =============================================================================

-- =============================================================================
-- 1. CREAZIONE SCHEMA E TABELLE
-- =============================================================================

DROP SCHEMA IF EXISTS frutta_srl;
CREATE SCHEMA frutta_srl;

USE frutta_srl;

-- -----------------------------------------------------------------------------
-- Fornitore
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Fornitore;
CREATE TABLE Fornitore (
    Codice  VARCHAR(10)  NOT NULL,
    CF      CHAR(16)     NOT NULL,
    Nome    VARCHAR(100) NOT NULL,
    CONSTRAINT pk_fornitore  PRIMARY KEY (Codice),
    CONSTRAINT uq_fornitore_cf UNIQUE (CF)
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Indirizzo
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Indirizzo;
CREATE TABLE Indirizzo (
    Valore    VARCHAR(120) NOT NULL,
    Fornitore VARCHAR(10)  NOT NULL,
    CONSTRAINT pk_indirizzo PRIMARY KEY (Valore),
    CONSTRAINT fk_indirizzo_fornitore
        FOREIGN KEY (Fornitore) REFERENCES Fornitore(Codice)
        ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Prodotto
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Prodotto;
CREATE TABLE Prodotto (
    Codice     VARCHAR(20)            NOT NULL,
    Nome       VARCHAR(100)           NOT NULL,
    Categoria  ENUM('frutta','verdura') NOT NULL,
    Prezzo_kg  DECIMAL(6,2) UNSIGNED  NOT NULL,
    CONSTRAINT pk_prodotto PRIMARY KEY (Codice)
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Fornitura
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Fornitura;
CREATE TABLE Fornitura (
    Fornitore VARCHAR(10) NOT NULL,
    Prodotto  VARCHAR(20) NOT NULL,
    CONSTRAINT pk_fornitura PRIMARY KEY (Fornitore, Prodotto),
    CONSTRAINT fk_fornitura_fornitore
        FOREIGN KEY (Fornitore) REFERENCES Fornitore(Codice)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fornitura_prodotto
        FOREIGN KEY (Prodotto)  REFERENCES Prodotto(Codice)
        ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Prodotto_in_magazzino
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Prodotto_in_magazzino;
CREATE TABLE Prodotto_in_magazzino (
    Prodotto       VARCHAR(20)   NOT NULL,
    Data_arrivo    DATE          NOT NULL,
    Quantita       DECIMAL(10,2) UNSIGNED NOT NULL,
    Data_scadenza  DATE          NOT NULL,
    CONSTRAINT pk_prodotto_in_magazzino PRIMARY KEY (Prodotto, Data_arrivo),
    CONSTRAINT fk_pim_prodotto
        FOREIGN KEY (Prodotto) REFERENCES Prodotto(Codice)
        ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Cliente
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Cliente;
CREATE TABLE Cliente (
    PIVA         CHAR(11)     NOT NULL,
    Nome         VARCHAR(100) NOT NULL,
    Residenza    VARCHAR(120) NOT NULL,
    Fatturazione VARCHAR(120) NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (PIVA)
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Contatto_cliente
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Contatto_cliente;
CREATE TABLE Contatto_cliente (
    Valore  VARCHAR(100)                        NOT NULL,
    Tipo    ENUM('telefono','cellulare','email') NOT NULL,
    Cliente CHAR(11)                            NOT NULL,
    CONSTRAINT pk_contatto_cliente PRIMARY KEY (Valore),
    CONSTRAINT fk_contatto_cliente_cliente
        FOREIGN KEY (Cliente) REFERENCES Cliente(PIVA)
        ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Ordine
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Ordine;
CREATE TABLE Ordine (
    Codice               INT          NOT NULL AUTO_INCREMENT,
    Indirizzo_spedizione VARCHAR(120) NOT NULL,
    Data_e_Ora           DATETIME     NOT NULL,
    PIVA_Cliente         CHAR(11)     NOT NULL,
    Contatto             VARCHAR(100) NOT NULL,
    CONSTRAINT pk_ordine PRIMARY KEY (Codice),
    CONSTRAINT fk_ordine_cliente
        FOREIGN KEY (PIVA_Cliente) REFERENCES Cliente(PIVA)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ordine_contatto
        FOREIGN KEY (Contatto) REFERENCES Contatto_cliente(Valore)
        ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Contenuto_ordine
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Contenuto_ordine;
CREATE TABLE Contenuto_ordine (
    Prodotto  VARCHAR(20)   NOT NULL,
    Ordine    INT           NOT NULL,
    Quantita  DECIMAL(10,2) UNSIGNED NOT NULL,
    CONSTRAINT pk_contenuto_ordine PRIMARY KEY (Prodotto, Ordine),
    CONSTRAINT fk_co_prodotto
        FOREIGN KEY (Prodotto) REFERENCES Prodotto(Codice)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_co_ordine
        FOREIGN KEY (Ordine) REFERENCES Ordine(Codice)
        ON DELETE CASCADE ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -----------------------------------------------------------------------------
-- Utenti
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Utenti;
CREATE TABLE Utenti (
    Username VARCHAR(45)                       NOT NULL,
    Password CHAR(32)                          NOT NULL,   -- MD5 della password
    Ruolo    ENUM('operatore vendite','magazziniere') NOT NULL,
    CONSTRAINT pk_utenti PRIMARY KEY (Username)
)
ENGINE = InnoDB;


-- =============================================================================
-- 2. INDICI
-- =============================================================================
CREATE INDEX idx_scadenza ON Prodotto_in_magazzino (Data_scadenza);


-- =============================================================================
-- 3. TRIGGER
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Trigger 1
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS check_almeno_un_contatto$$
CREATE TRIGGER check_almeno_un_contatto
BEFORE DELETE ON Contatto_cliente
FOR EACH ROW
BEGIN
    DECLARE n INT;
    SELECT COUNT(*) INTO n
    FROM Contatto_cliente
    WHERE Cliente = OLD.Cliente;
    IF n <= 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Il cliente deve avere almeno un contatto registrato';
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Trigger 2
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS check_contatto_cliente$$
CREATE TRIGGER check_contatto_cliente
BEFORE INSERT ON Ordine
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Contatto_cliente
        WHERE Valore  = NEW.Contatto
          AND Cliente = NEW.PIVA_Cliente
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Il contatto fornito non appartiene al cliente';
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Trigger 3
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS check_disponibilita_magazzino$$
CREATE TRIGGER check_disponibilita_magazzino
BEFORE INSERT ON Contenuto_ordine
FOR EACH ROW
BEGIN
    DECLARE disponibile DECIMAL(10,2);
    SELECT COALESCE(SUM(Quantita), 0) INTO disponibile
    FROM Prodotto_in_magazzino
    WHERE Prodotto = NEW.Prodotto;

    IF disponibile < NEW.Quantita THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantità disponibile in magazzino insufficiente';
    END IF;
END$$
DELIMITER ;


-- =============================================================================
-- 4. EVENTI
-- =============================================================================

-- Abilita lo scheduler degli eventi (necessario per CREATE EVENT)
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS cleanup;
CREATE EVENT IF NOT EXISTS cleanup
ON SCHEDULE
    EVERY 1 WEEK
        ON COMPLETION PRESERVE
COMMENT 'Rimozione ordini scaduti (mantenuti al massimo 3 mesi)'
DO
    DELETE FROM Ordine
    WHERE Data_e_Ora < (NOW() - INTERVAL 3 MONTH);


-- =============================================================================
-- 5. STORED PROCEDURES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Operazione L -- Login utente
-- Restituisce: 1 = operatore vendite, 2 = magazziniere, 0 = credenziali errate
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS Login$$
CREATE PROCEDURE Login(
    IN  p_username VARCHAR(45),
    IN  p_password CHAR(32),
    OUT p_ruolo    INT
)
BEGIN
    DECLARE v_ruolo ENUM('operatore vendite','magazziniere');
    SELECT Ruolo INTO v_ruolo
    FROM Utenti
    WHERE Username = p_username
      AND Password = MD5(p_password);
    IF v_ruolo = 'operatore vendite' THEN
        SET p_ruolo = 1;
    ELSEIF v_ruolo = 'magazziniere' THEN
        SET p_ruolo = 2;
    ELSE
        SET p_ruolo = 0;
    END IF;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Operazione S (1/2) -- CreaOrdine
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS CreaOrdine$$
CREATE PROCEDURE CreaOrdine(
    IN  p_indirizzo VARCHAR(120),
    IN  p_piva      CHAR(11),
    IN  p_contatto  VARCHAR(100),
    OUT p_codice    INT
)
BEGIN
    INSERT INTO Ordine(Indirizzo_spedizione, Data_e_Ora, PIVA_Cliente, Contatto)
    VALUES (p_indirizzo, NOW(), p_piva, p_contatto);
    SET p_codice = LAST_INSERT_ID();
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Operazione S (2/2) -- InserisciProdottoOrdine
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS InserisciProdottoOrdine$$
CREATE PROCEDURE InserisciProdottoOrdine(
    IN p_ordine   INT,
    IN p_prodotto VARCHAR(20),
    IN p_quantita DECIMAL(10,2)
)
BEGIN
    DECLARE v_rimanente DECIMAL(10,2);
    DECLARE v_data      DATE;
    DECLARE v_qty       DECIMAL(10,2);
    DECLARE v_done      INT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT Data_arrivo, Quantita
        FROM Prodotto_in_magazzino
        WHERE Prodotto = p_prodotto AND Quantita > 0
        ORDER BY Data_scadenza ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SET TRANSACTION READ WRITE;
    START TRANSACTION;

        -- Inserimento in Contenuto_ordine (trigger check_disponibilita_magazzino
        -- verifica la disponibilità complessiva prima di procedere)
        INSERT INTO Contenuto_ordine(Prodotto, Ordine, Quantita)
        VALUES (p_prodotto, p_ordine, p_quantita);

        SET v_rimanente = p_quantita;
        OPEN cur;

        scarico_loop: LOOP
            FETCH cur INTO v_data, v_qty;
            IF v_done OR v_rimanente <= 0 THEN
                LEAVE scarico_loop;
            END IF;

            IF v_qty <= v_rimanente THEN
                -- Lotto esaurito: si elimina il record
                DELETE FROM Prodotto_in_magazzino
                WHERE Prodotto = p_prodotto AND Data_arrivo = v_data;
                SET v_rimanente = v_rimanente - v_qty;
            ELSE
                -- Lotto parzialmente consumato
                UPDATE Prodotto_in_magazzino
                SET Quantita = Quantita - v_rimanente
                WHERE Prodotto = p_prodotto AND Data_arrivo = v_data;
                SET v_rimanente = 0;
            END IF;
        END LOOP;

        CLOSE cur;
    COMMIT;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Operazione M1 -- ReportScadenze
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS ReportScadenze$$
CREATE PROCEDURE ReportScadenze()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET TRANSACTION READ ONLY;
    START TRANSACTION;

        SELECT
            DATE(pm.Data_scadenza)  AS Giorno,
            p.Codice,
            p.Nome,
            p.Categoria,
            SUM(pm.Quantita)        AS Quantita_totale
        FROM Prodotto_in_magazzino pm
        JOIN Prodotto p ON pm.Prodotto = p.Codice
        WHERE pm.Data_scadenza BETWEEN CURDATE() AND CURDATE() + INTERVAL 7 DAY
        GROUP BY DATE(pm.Data_scadenza), p.Codice, p.Nome, p.Categoria
        ORDER BY Giorno ASC;

    COMMIT;
END$$
DELIMITER ;

-- -----------------------------------------------------------------------------
-- Operazione M2 -- RegistraProdottoMagazzino
-- -----------------------------------------------------------------------------
DELIMITER $$
DROP PROCEDURE IF EXISTS RegistraProdottoMagazzino$$
CREATE PROCEDURE RegistraProdottoMagazzino(
    IN p_prodotto      VARCHAR(20),
    IN p_data_arrivo   DATE,
    IN p_quantita      DECIMAL(10,2),
    IN p_data_scadenza DATE
)
BEGIN
    DECLARE v_quantita_vecchia DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    SET TRANSACTION READ WRITE;
    START TRANSACTION;

        SELECT Quantita INTO v_quantita_vecchia
        FROM Prodotto_in_magazzino
        WHERE Prodotto = p_prodotto AND Data_arrivo = p_data_arrivo;

        IF v_quantita_vecchia IS NULL THEN
            INSERT INTO Prodotto_in_magazzino(Prodotto, Data_arrivo, Quantita, Data_scadenza)
            VALUES (p_prodotto, p_data_arrivo, p_quantita, p_data_scadenza);
        ELSE
            UPDATE Prodotto_in_magazzino
            SET Quantita = Quantita + p_quantita
            WHERE Prodotto = p_prodotto AND Data_arrivo = p_data_arrivo;
        END IF;

    COMMIT;
END$$
DELIMITER ;


-- =============================================================================
-- 6. GRANT (utenti applicativi)
-- =============================================================================
-- Nota: sostituire 'password_xxx' con i valori reali dell'ambiente.

-- Utente login: può solo eseguire la procedura Login
DROP USER IF EXISTS login;
CREATE USER 'login' IDENTIFIED BY 'login';
GRANT EXECUTE ON PROCEDURE Login TO 'login';

-- Operatore vendite: può eseguire CreaOrdine e InserisciProdottoOrdine
DROP USER IF EXISTS operatore_vendite;
CREATE USER 'operatore_vendite' IDENTIFIED BY 'operatore_vendite';
GRANT EXECUTE ON PROCEDURE CreaOrdine              TO 'operatore_vendite';
GRANT EXECUTE ON PROCEDURE InserisciProdottoOrdine TO 'operatore_vendite';

-- Magazziniere: può eseguire ReportScadenze e RegistraProdottoMagazzino
DROP USER IF EXISTS magazziniere;
CREATE USER 'magazziniere' IDENTIFIED BY 'magazziniere';
GRANT EXECUTE ON PROCEDURE ReportScadenze           TO 'magazziniere';
GRANT EXECUTE ON PROCEDURE RegistraProdottoMagazzino TO 'magazziniere';

-- =============================================================================
-- 7. POPOLAMENTO DATI DI ESEMPIO
-- =============================================================================

START TRANSACTION;

-- Password per entrambi: password123
INSERT INTO Utenti (Username, Password, Ruolo) VALUES
('m.rossi', '482c811da5d5b4bc6d497ffa98491e38', 'operatore vendite'),
('g.bianchi', '482c811da5d5b4bc6d497ffa98491e38', 'magazziniere');

INSERT INTO Fornitore (Codice, CF, Nome) VALUES
('FOR01', 'RSSMRA85A01F205Z', 'Frutteto del Sole S.r.l.'),
('FOR02', 'BNCGNN90T15H501Y', 'Ortofrutta Lazio di Bianchi'),
('FOR03', 'VRDLRA95E41L219W', 'BioVerde Agricola'),
('FOR04', 'NROFRC00M22F205N', 'Consorzio Agrario Pontino');

INSERT INTO Indirizzo (Valore, Fornitore) VALUES
('Via delle Industrie 15, Latina', 'FOR01'),
('Via Appia Nuova km 45, Velletri', 'FOR02'),
('Via Casilina 1200, Roma', 'FOR03'),
('Strada Migliara 47, Sabaudia', 'FOR04');

INSERT INTO Prodotto (Codice, Nome, Categoria, Prezzo_kg) VALUES
('MELA_GALA', 'Mela Gala', 'frutta', 1.80),
('BANANA_CH', 'Banana Chiquita', 'frutta', 2.20),
('ARANCIA_TAR', 'Arancia Tarocco', 'frutta', 2.00),
('FRAGO_BAS', 'Fragola Candonga', 'frutta', 4.50),
('POMO_PACH', 'Pomodoro Pachino', 'verdura', 2.50),
('ZUCCH_ROM', 'Zucchina Romanesca', 'verdura', 1.90),
('PATATA_BOL', 'Patata di Bologna DOP', 'verdura', 1.30);

INSERT INTO Fornitura (Fornitore, Prodotto) VALUES
('FOR01', 'MELA_GALA'),
('FOR01', 'ARANCIA_TAR'),
('FOR02', 'BANANA_CH'),
('FOR02', 'POMO_PACH'),
('FOR03', 'FRAGO_BAS'),
('FOR03', 'PATATA_BOL'),
('FOR04', 'ZUCCH_ROM'),
('FOR04', 'POMO_PACH');

INSERT INTO Prodotto_in_magazzino (Prodotto, Data_arrivo, Quantita, Data_scadenza) VALUES
-- Prodotti in scadenza nella settimana del 15 giugno
('MELA_GALA', '2026-06-10', 150.00, '2026-06-19'),
('MELA_GALA', '2026-06-12', 200.00, '2026-06-22'),
('BANANA_CH', '2026-06-14', 80.00, '2026-06-18'),
('FRAGO_BAS', '2026-06-15', 45.00, '2026-06-20'),
('POMO_PACH', '2026-06-13', 120.00, '2026-06-23'),
-- Prodotti scaduti prima del 15
('ZUCCH_ROM', '2026-06-05', 10.00, '2026-06-12'),
-- Prodotti non in scadenza nella settimana del 15 giugno
('PATATA_BOL', '2026-06-01', 600.00, '2026-07-30'),
('ARANCIA_TAR', '2026-06-09', 300.00, '2026-07-10');

INSERT INTO Cliente (PIVA, Nome, Residenza, Fatturazione) VALUES
('12345678901', 'Supermercati PAM S.p.A.', 'Via Tuscolana 400, Roma', 'Via Tuscolana 400, Roma'),
('98765432109', 'Ristorante Da Ciro', 'Via Roma 12, Frascati', 'Via Roma 12, Frascati'),
('55566677788', 'Hotel Splendid', 'Via Veneto 80, Roma', 'Via Veneto 80, Roma');

INSERT INTO Contatto_cliente (Valore, Tipo, Cliente) VALUES
('06778899', 'telefono', '12345678901'),
('pam.roma@email.it', 'email', '12345678901'),
('3331122334', 'cellulare', '98765432109'),
('info@ristorantedaciro.it', 'email', '98765432109'),
('direzione@hotelsplendid.it', 'email', '55566677788');

INSERT INTO Ordine (Codice, Indirizzo_spedizione, Data_e_Ora, PIVA_Cliente, Contatto) VALUES
(1, 'Centro Distribuzione PAM, Via Palmiro Togliatti, Roma', '2026-05-20 10:30:00', '12345678901', 'pam.roma@email.it'),
(2, 'Via Roma 12, Frascati', '2026-06-15 09:15:00', '98765432109', '3331122334'),
-- Ordine vecchio (soggetto all'evento di cleanup)
(3, 'Via Veneto 80, Roma', '2026-02-10 16:00:00', '55566677788', 'direzione@hotelsplendid.it');

INSERT INTO Contenuto_ordine (Prodotto, Ordine, Quantita) VALUES
('MELA_GALA', 1, 50.00),
('BANANA_CH', 1, 30.00),
('POMO_PACH', 2, 15.00),
('PATATA_BOL', 3, 100.00);

COMMIT;