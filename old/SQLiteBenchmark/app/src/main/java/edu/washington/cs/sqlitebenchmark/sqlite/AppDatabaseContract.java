package edu.washington.cs.sqlitebenchmark.sqlite;

import android.provider.BaseColumns;

/**
 * Created by nl35 on 11/17/17.
 *
 * Based on https://developer.android.com/training/data-storage/sqlite.html.
 */

public final class AppDatabaseContract {
    private AppDatabaseContract() {}

    public static class AppDatabase implements BaseColumns {
        public static final String TABLE_NAME = "User";
        public static final String COLUMN_NAME_FIRSTNAME = "firstName";
        public static final String COLUMN_NAME_LASTNAME = "lastName";
        public static final String COLUMN_NAME_STATUS = "status";
    }
}
