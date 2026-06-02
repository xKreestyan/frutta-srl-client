package it.basi.fruttasrl.controller;

import it.basi.fruttasrl.dao.LoginDAO;
import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.domain.UserCredentials;
import it.basi.fruttasrl.model.dto.LoginRequest;
import it.basi.fruttasrl.view.LoginView;

import java.io.IOException;

public class LoginController implements Controller {
    UserCredentials cred = null;

    @Override
    public void start() {
        try {
            cred = LoginView.authenticate();
        } catch(IOException e) {
            throw new RuntimeException(e);
        }

        LoginRequest loginRequest = new LoginRequest(cred.getUsername(), cred.getPassword()); //DTO per poi chiamare la procedura di login. Ogni volta che voglio chiamare una stored procedure uso un DTO per incapsulare solo i dati necessari e passare quelli alla stored procedure
        //un DTO tipicamente ha un costruttore, dei getter, ma non dei setter in quanto oggetto immutabile usato solo per chiamare la stored procedure

        try {
            cred = new LoginDAO().execute(loginRequest); //"chiamo" del codice SQL dal DAO passando il DTO
        } catch(DAOException e) {
            throw new RuntimeException(e);
        }
    }

    public UserCredentials getCred() {
        return cred;
    }
}
