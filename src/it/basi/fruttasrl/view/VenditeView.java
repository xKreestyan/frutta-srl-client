package it.basi.fruttasrl.view;

import it.basi.fruttasrl.model.dto.CreaOrdineRequest;
import it.basi.fruttasrl.model.dto.InserisciProdottoRequest;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class VenditeView {
    private static final BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

    public static void mostraMenu() {
        System.out.println("\n=== OPERATORE VENDITE ===");
        System.out.println("1. Inserisci ordine cliente");
        System.out.println("0. Esci");
        System.out.print("Scelta: ");
    }

    public static int leggiScelta() throws IOException {
        try {
            return Integer.parseInt(reader.readLine().trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    public static CreaOrdineRequest leggiDatiOrdine() throws IOException {
        System.out.print("Indirizzo di spedizione: ");
        String indirizzo = reader.readLine().trim();
        System.out.print("PIVA cliente: ");
        String piva = reader.readLine().trim();
        System.out.print("Contatto: ");
        String contatto = reader.readLine().trim();
        return new CreaOrdineRequest(indirizzo, piva, contatto);
    }

    public static void mostraOrdineCreato(int codice) {
        System.out.println("Ordine #" + codice + " creato. Inserisci i prodotti (invio su riga vuota per terminare).");
    }

    public static InserisciProdottoRequest leggiProdotto(int codiceOrdine) throws IOException {
        System.out.print("Codice prodotto: ");
        String prodotto = reader.readLine().trim();
        if (prodotto.isEmpty()) return null;
        System.out.print("Quantità (kg): ");
        double quantita = Double.parseDouble(reader.readLine().trim());
        return new InserisciProdottoRequest(codiceOrdine, prodotto, quantita);
    }

    public static void mostraProdottoInserito(String prodotto) {
        System.out.println("Prodotto " + prodotto + " aggiunto all'ordine.");
    }

    public static void mostraOrdineCompletato(int codice) {
        System.out.println("Ordine #" + codice + " completato.");
    }

    public static void mostraOrdineAnnullato(int codice) {
        System.out.println("Nessun prodotto inserito. Ordine #" + codice + " annullato.");
    }

    public static void mostraErrore(String messaggio) {
        System.err.println("Errore: " + messaggio);
    }

    public static void mostraSceltaNonValida() {
        System.out.println("Scelta non valida.");
    }
}