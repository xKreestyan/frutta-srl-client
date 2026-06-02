package it.basi.fruttasrl.view;

import it.basi.fruttasrl.model.UserCredentials;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class LoginView {
    public static UserCredentials authenticate() throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in)); //stdin in uno InputStreamReader bufferizzato con BufferedReader
        System.out.print("username: ");
        String username = reader.readLine(); //si stoppa quando si introduce '\n'
        System.out.print("password: ");
        String password = reader.readLine();

        return new UserCredentials(username, password, null); //il controller tratta oggetti di dominio => la view restituisce un POJO con username, password e ruolo (per ora nullo perché non lo abbiamo ancora)
    }
}
