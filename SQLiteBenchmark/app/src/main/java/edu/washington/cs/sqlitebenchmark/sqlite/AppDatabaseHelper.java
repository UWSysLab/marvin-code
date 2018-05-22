package edu.washington.cs.sqlitebenchmark.sqlite;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

/**
 * Created by nl35 on 11/17/17.
 *
 * Based on https://developer.android.com/training/data-storage/sqlite.html.
 */

public class AppDatabaseHelper extends SQLiteOpenHelper {
    public static final int DATABASE_VERSION = 1;
    public static final String DATABASE_NAME = "AppDatabase.db";

    private static final String SQL_CREATE_ENTRIES =
            "CREATE TABLE " + AppDatabaseContract.AppDatabase.TABLE_NAME + " (" +
            AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME + " TEXT," +
            AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + " TEXT," +
            AppDatabaseContract.AppDatabase.COLUMN_NAME_STATUS + " TEXT," +
            "PRIMARY KEY (" + AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME
                    + ", " + AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + ")" +
            ")";

    private static final String SQL_DELETE_ENTRIES =
            "DROP TABLE IF EXISTS " + AppDatabaseContract.AppDatabase.TABLE_NAME;

    private static final String SQL_CREATE_INDEX =
            "CREATE UNIQUE INDEX nameIndex ON " + AppDatabaseContract.AppDatabase.TABLE_NAME +
            " (" + AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME + ", " +
            AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + ")";

    public AppDatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL(SQL_CREATE_ENTRIES);
        db.execSQL(SQL_CREATE_INDEX);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL(SQL_DELETE_ENTRIES);
        onCreate(db);
    }
}
