package it.basi.fruttasrl.model.dto;

import java.time.LocalDate;

public record RegistrazioneRequest(String prodotto, LocalDate dataArrivo, double quantita, LocalDate dataScadenza) {
}
