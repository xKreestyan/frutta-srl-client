package it.basi.fruttasrl.model.dto;

import java.time.LocalDate;

public record ScadenzaRow(LocalDate giorno, String codice, String nome, String categoria, double quantitaTotale) {
}
