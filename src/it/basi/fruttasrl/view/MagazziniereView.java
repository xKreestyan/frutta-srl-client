package it.basi.fruttasrl.view;

import it.basi.fruttasrl.model.dto.RegistrazioneRequest;
import it.basi.fruttasrl.model.dto.ScadenzaRow;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

public class MagazziniereView {
    private static final BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

    public static void mostraMenu() {
        System.out.println("\n=== MAGAZZINIERE ===");
        System.out.println("1. Genera report dei prodotti in magazzino in scadenza nei prossimi 7 giorni");
        System.out.println("2. Registra prodotto in magazzino a seguito di rifornimento");
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

    public static void mostraReportScadenze(List<ScadenzaRow> report) {
        if (report.isEmpty()) {
            System.out.println("Nessun prodotto in scadenza nei prossimi 7 giorni.");
            return;
        }
        System.out.println("\n--- REPORT SCADENZE ---");
        System.out.printf("%-12s %-15s %-25s %-10s %10s%n",
                "Giorno", "Codice", "Nome", "Categoria", "Qt. tot. (kg)");
        System.out.println("-".repeat(76));
        for (ScadenzaRow row : report) {
            System.out.printf("%-12s %-15s %-25s %-10s %10.2f%n",
                    row.giorno(),
                    row.codice(),
                    row.nome(),
                    row.categoria(),
                    row.quantitaTotale());
        }
    }

    public static RegistrazioneRequest leggiDatiRegistrazione() throws IOException {
        System.out.print("Codice prodotto: ");
        String prodotto = reader.readLine().trim();

        LocalDate dataArrivo = leggiData("Data arrivo (YYYY-MM-DD): ");
        System.out.print("Quantità (kg): ");
        double quantita = Double.parseDouble(reader.readLine().trim());
        LocalDate dataScadenza = leggiData("Data scadenza (YYYY-MM-DD): ");

        return new RegistrazioneRequest(prodotto, dataArrivo, quantita, dataScadenza);
    }

    private static LocalDate leggiData(String prompt) throws IOException {
        while (true) {
            System.out.print(prompt);
            try {
                return LocalDate.parse(reader.readLine().trim());
            } catch (DateTimeParseException e) {
                System.out.println("Formato non valido. Usa YYYY-MM-DD.");
            }
        }
    }

    public static void mostraRegistrazioneAvvenuta() {
        System.out.println("Prodotto registrato in magazzino con successo.");
    }

    public static void mostraErrore(String messaggio) {
        System.err.println("Errore: " + messaggio);
    }

    public static void mostraSceltaNonValida() {
        System.out.println("Scelta non valida.");
    }
}
