package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.dto.RegistrazioneRequest;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.SQLException;

public class RegistraProdottoMagazzinoDAO implements GenericProcedureDAO<RegistrazioneRequest, Void> {
    @Override
    public Void execute(RegistrazioneRequest input) throws DAOException {
        try {
            Connection conn = ConnectionFactory.getConnection();
            CallableStatement cs = conn.prepareCall("{call RegistraProdottoMagazzino(?,?,?,?)}");
            cs.setString(1, input.prodotto());
            cs.setDate(2, Date.valueOf(input.dataArrivo()));
            cs.setDouble(3, input.quantita());
            cs.setDate(4, Date.valueOf(input.dataScadenza()));
            cs.executeUpdate();
            return null;
        } catch (SQLException e) {
            throw new DAOException("Errore durante la registrazione del prodotto: " + e.getMessage(), e);
        }
    }
}
