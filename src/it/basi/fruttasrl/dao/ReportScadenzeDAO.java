package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.dto.ScadenzaRow;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReportScadenzeDAO implements GenericProcedureDAO<Void, List<ScadenzaRow>> {
    @Override
    public List<ScadenzaRow> execute(Void input) throws DAOException {
        List<ScadenzaRow> report = new ArrayList<>();
        try {
            Connection conn = ConnectionFactory.getConnection();
            CallableStatement cs = conn.prepareCall("{call ReportScadenze()}");
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                report.add(new ScadenzaRow(
                        rs.getDate("Giorno").toLocalDate(),
                        rs.getString("Codice"),
                        rs.getString("Nome"),
                        rs.getString("Categoria"),
                        rs.getDouble("Quantita_totale")
                ));
            }
        } catch (SQLException e) {
            throw new DAOException("Errore durante il report scadenze: " + e.getMessage(), e);
        }
        return report;
    }
}
