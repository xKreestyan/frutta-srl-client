package it.basi.fruttasrl.model.domain;

public enum Role {
    OPERATORE_VENDITE(1),
    MAGAZZINIERE(2);

    private final int id;

    private Role(int id) {
        this.id = id;
    }

    //itero su tutti i valori possibili, se il codice numerico corrisponde, restituisce il valore enumerato corrispondente, altrimenti null
    public static Role fromInt(int id) {
        for (Role type : values()) {
            if (type.getId() == id) {
                return type;
            }
        }
        return null;
    }

    public int getId() {
        return id;
    }
}
