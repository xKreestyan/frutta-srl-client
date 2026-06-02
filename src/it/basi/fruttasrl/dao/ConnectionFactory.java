package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.model.domain.Role;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class ConnectionFactory {
    private static Connection connection; //connessione singleton

    private ConnectionFactory() {}

    static { //creo la connessione quando il classloader carica la classe: il blocco static viene eseguito appena la carica
        // Does not work if generating a jar file (lo apro come percorso di filesystem e non come percorso nel jar)
        try (InputStream input = new FileInputStream("resources/db.properties")) { //provo ad aprire un file su disco con le credenziali, che sono in chiaro, ma il sistema operativo ha l'ACL apposita per il file: nessuno può accederci fuori dall'ambiente dell'applicazione
            Properties properties = new Properties(); //installa in memoria un dizionario chiave valore
            properties.load(input); //uso il file per il dizionario

            String connection_url = properties.getProperty("CONNECTION_URL");
            String user = properties.getProperty("LOGIN_USER");
            String pass = properties.getProperty("LOGIN_PASS");

            connection = DriverManager.getConnection(connection_url, user, pass); //mi connetto al DB
        } catch (IOException | SQLException e) { //catch composta che si avvia quando ricevo una delle due eccezioni
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return connection;
    }

    //chiudo la connessione precedente e ne riapro una nuova con il ruolo specifico
    public static void changeRole(Role role) throws SQLException {
        connection.close();

        try (InputStream input = new FileInputStream("resources/db.properties")) {
            Properties properties = new Properties();
            properties.load(input);

            String connection_url = properties.getProperty("CONNECTION_URL");
            String user = properties.getProperty(role.name() + "_USER");
            String pass = properties.getProperty(role.name() + "_PASS");

            connection = DriverManager.getConnection(connection_url, user, pass);
        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }
    }
}
