package it.basi.fruttasrl.dao;

//ogni classe che la implementa deve specificare nella signature due tipi generici (coppia I/O)

import it.basi.fruttasrl.exception.DAOException;

import java.sql.SQLException;

public interface GenericProcedureDAO<I,O> {
    O execute(I input) throws DAOException, SQLException;
    //le classi che la implementano, devono implementare un metodo execute che sputa un oggetto di tipo O e ne prende uno di tipo I
}
