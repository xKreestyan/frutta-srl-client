package it.basi.fruttasrl.model.dto;

public record LoginRequest(String username, String password) {
}

//la classe record implementa un record di dati (immutabile) che può essere solo consumato
//definisco nella signature i membri della classe e automaticamente java mi imposta il costruttore per inizializzare l'oggetto istanziato + i setter per ogni parametro
