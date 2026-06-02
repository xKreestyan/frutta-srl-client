package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.exception.DAOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class EliminaOrdineDAO implements GenericProcedureDAO<Integer, Void> {
    @Override
    public Void execute(Integer codiceOrdine) throws DAOException {
        try {
            Connection conn = ConnectionFactory.getConnection();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM Ordine WHERE Codice = ?");
            ps.setInt(1, codiceOrdine);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new DAOException("Errore durante l'eliminazione dell'ordine: " + e.getMessage(), e);
        }
        return null;
    }
}