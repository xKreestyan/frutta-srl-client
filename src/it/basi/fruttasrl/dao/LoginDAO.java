package it.basi.fruttasrl.dao;

import it.basi.fruttasrl.exception.DAOException;
import it.basi.fruttasrl.model.domain.UserCredentials;
import it.basi.fruttasrl.model.domain.Role;
import it.basi.fruttasrl.model.dto.LoginRequest;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;

public class LoginDAO implements GenericProcedureDAO<LoginRequest, UserCredentials> {
    @Override
    public UserCredentials execute(LoginRequest input) throws DAOException {
        String username = input.username();
        String password = input.password();
        int role; //ruolo è enumeratore

        try {
            Connection conn = ConnectionFactory.getConnection();
            CallableStatement cs = conn.prepareCall("{call login(?,?,?)}");
            cs.setString(1, username); //String compatibile con varchar, JDBC lo converte correttamente
            cs.setString(2, password);
            cs.registerOutParameter(3, Types.NUMERIC); //NUMERIC perché var_role è INT nella stored procedure in SQL
            cs.executeQuery();
            role = cs.getInt(3); //mi restituisce l'intero corrispondente al ruolo
        } catch(SQLException e) {
            throw new DAOException("Login error: " + e.getMessage());
        }


        return new UserCredentials(username, password, Role.fromInt(role)); //istanzio un oggetto di tipo Credentials passando una classe enum Role per tornare alla sintassi giusta per il ruolo
    }
}
