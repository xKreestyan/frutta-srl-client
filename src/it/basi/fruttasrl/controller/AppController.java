package it.basi.fruttasrl.controller;

import it.basi.fruttasrl.dao.ConnectionFactory;
import it.basi.fruttasrl.exception.AppException;
import it.basi.fruttasrl.model.domain.UserCredentials;

import java.sql.SQLException;

public class AppController implements Controller {
    UserCredentials cred;

    @Override
    public void start() throws AppException {
        LoginController loginController = new LoginController(); //controller per il login
        loginController.start();
        cred = loginController.getCred(); //prendo le credenziali: se il ruolo è null allora RuntimeException

        if(cred.getRole() == null) {
            throw new RuntimeException("Invalid credentials");
        }

        try {
            ConnectionFactory.changeRole(cred.getRole());
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        switch(cred.getRole()) { //a seconda del ruolo cambio modalità operativa dell'applicazione
            case OPERATORE_VENDITE -> new VenditeController().start();
            case MAGAZZINIERE -> new MagazziniereController().start();
            default -> throw new RuntimeException("Invalid credentials");
        }
    }
}
