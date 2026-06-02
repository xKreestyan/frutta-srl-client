package it.basi.fruttasrl.controller;

import it.basi.fruttasrl.dao.CreaOrdineDAO;
import it.basi.fruttasrl.dao.EliminaOrdineDAO;
import it.basi.fruttasrl.dao.InserisciProdottoOrdineDAO;
import it.basi.fruttasrl.exception.AppException;
import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.dto.CreaOrdineRequest;
import it.basi.fruttasrl.model.dto.InserisciProdottoRequest;
import it.basi.fruttasrl.view.VenditeView;

import java.io.IOException;

public class VenditeController implements Controller {
    @Override
    public void start() throws AppException {
        boolean running = true;
        while (running) {
            try {
                VenditeView.mostraMenu();
                int scelta = VenditeView.leggiScelta();
                switch (scelta) {
                    case 1 -> gestisciOrdine();
                    case 0 -> running = false;
                    default -> VenditeView.mostraSceltaNonValida();
                }
            } catch (IOException e) {
                throw new AppException("Errore di I/O: " + e.getMessage(), e);
            }
        }
    }

    private void gestisciOrdine() throws IOException {
        try {
            CreaOrdineRequest reqOrdine = VenditeView.leggiDatiOrdine();
            int codiceOrdine = new CreaOrdineDAO().execute(reqOrdine);
            VenditeView.mostraOrdineCreato(codiceOrdine);

            int prodottiInseriti = 0;

            while (true) {
                InserisciProdottoRequest reqProdotto = VenditeView.leggiProdotto(codiceOrdine);
                if (reqProdotto == null) break;
                try {
                    new InserisciProdottoOrdineDAO().execute(reqProdotto);
                    VenditeView.mostraProdottoInserito(reqProdotto.prodotto());
                    prodottiInseriti++;
                } catch (DAOException e) {
                    VenditeView.mostraErrore(e.getMessage());
                }
            }

            if (prodottiInseriti == 0) {
                new EliminaOrdineDAO().execute(codiceOrdine);
                VenditeView.mostraOrdineAnnullato(codiceOrdine);
            } else {
                VenditeView.mostraOrdineCompletato(codiceOrdine);
            }

        } catch (DAOException e) {
            VenditeView.mostraErrore(e.getMessage());
        }
    }
}