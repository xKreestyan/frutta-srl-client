package it.basi.fruttasrl.controller;

import it.basi.fruttasrl.exception.AppException;
import it.basi.fruttasrl.model.UserCredentials;

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

        switch(cred.getRole()) { //a seconda del ruolo cambio modalità operativa dell'applicazione
            case OPERATORE_VENDITE -> new VenditeController().start();
            case MAGAZZINIERE -> new MagazziniereController().start();
            default -> throw new RuntimeException("Invalid credentials");
        }
    }
}
