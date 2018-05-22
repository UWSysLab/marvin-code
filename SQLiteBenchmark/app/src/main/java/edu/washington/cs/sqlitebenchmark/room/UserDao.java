package edu.washington.cs.sqlitebenchmark.room;

import android.arch.persistence.room.Dao;
import android.arch.persistence.room.Delete;
import android.arch.persistence.room.Insert;
import android.arch.persistence.room.Query;

import java.util.List;

/**
 * Created by nl35 on 11/13/17.
 */

@Dao
public interface UserDao {
    @Insert
    public void insertUser(User user);

    @Delete
    public void deleteUser(User user);

    @Query("SELECT status FROM User WHERE firstName LIKE :firstName AND lastName LIKE :lastName")
    public List<String> getStatus(String firstName, String lastName);

    @Query("Select * FROM User")
    public List<User> getAllUsers();

    @Query("UPDATE User SET status = :status WHERE firstName = :firstName AND lastName = :lastName")
    public void setStatus(String firstName, String lastName, String status);
}
