package it.basi.fruttasrl;

import it.basi.fruttasrl.controller.AppController;
import it.basi.fruttasrl.exception.AppException;

public class Main {
    public static void main(String[] args) {
        try {
            AppController applicationController = new AppController();
            applicationController.start();
        } catch (AppException e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
    }
}