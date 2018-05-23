package edu.washington.cs.sqlitebenchmark.room;

import android.arch.persistence.room.Database;
import android.arch.persistence.room.RoomDatabase;

/**
 * Created by nl35 on 11/13/17.
 */

@Database(version = 1, entities = {User.class})
public abstract class AppDatabase extends RoomDatabase {
    public abstract UserDao userDao();
}
