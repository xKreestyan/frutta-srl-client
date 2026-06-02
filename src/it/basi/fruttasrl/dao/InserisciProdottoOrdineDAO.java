package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.dto.InserisciProdottoRequest;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;

public class InserisciProdottoOrdineDAO implements GenericProcedureDAO<InserisciProdottoRequest, Void> {
    @Override
    public Void execute(InserisciProdottoRequest input) throws DAOException {
        try {
            Connection conn = ConnectionFactory.getConnection();
            CallableStatement cs = conn.prepareCall("{call InserisciProdottoOrdine(?,?,?)}");
            cs.setInt(1, input.ordine());
            cs.setString(2, input.prodotto());
            cs.setDouble(3, input.quantita());
            cs.executeUpdate();
            return null;
        } catch (SQLException e) {
            throw new DAOException("Errore durante l'inserimento del prodotto nell'ordine: " + e.getMessage(), e);
        }
    }
}
