package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.dto.CreaOrdineRequest;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

public class CreaOrdineDAO implements GenericProcedureDAO<CreaOrdineRequest, Integer> {
    @Override
    public Integer execute(CreaOrdineRequest input) throws DAOException {
        try {
            Connection conn = ConnectionFactory.getConnection();
            CallableStatement cs = conn.prepareCall("{call CreaOrdine(?,?,?,?)}");
            cs.setString(1, input.indirizzo());
            cs.setString(2, input.piva());
            cs.setString(3, input.contatto());
            cs.registerOutParameter(4, Types.INTEGER);
            cs.executeUpdate();
            return cs.getInt(4);
        } catch (SQLException e) {
            throw new DAOException("Errore durante la creazione dell'ordine: " + e.getMessage(), e);
        }
    }
}
