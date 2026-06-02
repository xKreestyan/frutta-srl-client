package it.basi.fruttasrl.controller;

import it.basi.fruttasrl.dao.RegistraProdottoMagazzinoDAO;
import it.basi.fruttasrl.dao.ReportScadenzeDAO;
import it.basi.fruttasrl.exception.AppException;
import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.dto.RegistrazioneRequest;
import it.basi.fruttasrl.model.dto.ScadenzaRow;
import it.basi.fruttasrl.view.MagazziniereView;

import java.io.IOException;
import java.util.List;

public class MagazziniereController implements Controller {
    @Override
    public void start() throws AppException {
        boolean running = true;
        while (running) {
            try {
                MagazziniereView.mostraMenu();
                int scelta = MagazziniereView.leggiScelta();
                switch (scelta) {
                    case 1 -> {
                        List<ScadenzaRow> report = new ReportScadenzeDAO().execute(null);
                        MagazziniereView.mostraReportScadenze(report);
                    }
                    case 2 -> {
                        RegistrazioneRequest req = MagazziniereView.leggiDatiRegistrazione();
                        new RegistraProdottoMagazzinoDAO().execute(req);
                        MagazziniereView.mostraRegistrazioneAvvenuta();
                    }
                    case 0 -> running = false;
                    default -> MagazziniereView.mostraSceltaNonValida();
                }
            } catch (DAOException e) {
                MagazziniereView.mostraErrore(e.getMessage());
            } catch (IOException e) {
                throw new AppException("Errore di I/O: " + e.getMessage(), e);
            }
        }
    }
}
