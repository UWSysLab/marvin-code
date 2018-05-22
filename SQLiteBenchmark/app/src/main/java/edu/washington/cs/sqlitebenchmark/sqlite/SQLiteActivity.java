package edu.washington.cs.sqlitebenchmark.sqlite;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

import edu.washington.cs.sqlitebenchmark.R;

public class SQLiteActivity extends AppCompatActivity {
    private static final String TAG = "SQLiteActivity";

    private AppDatabaseHelper appDbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sqlite);

        appDbHelper = new AppDatabaseHelper(getApplicationContext());

        Button prepDbButton = findViewById(R.id.sqlitePrepDbButton);
        prepDbButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new AsyncTask<Void, Void, Void>() {

                    @Override
                    protected Void doInBackground(Void... voids) {
                        doReads();
                        doCleanup();
                        doReads();
                        doSetup();
                        doReads();
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void result) {
                        Toast.makeText(getApplicationContext(), "Done with setup", Toast.LENGTH_SHORT).show();
                    }
                }.execute();
            }
        });

        Button benchmarkButton = findViewById(R.id.sqliteBenchmarkButton);
        benchmarkButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new AsyncTask<Void, Void, Void>() {

                    @Override
                    protected Void doInBackground(Void... voids) {
                        doReads();
                        doRepeatedWrites(1000);
                        doReads();
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void result) {
                        Toast.makeText(getApplicationContext(), "Done with benchmark", Toast.LENGTH_SHORT).show();
                    }
                }.execute();
            }
        });
    }

    private void doSetup() {
        SQLiteDatabase db = appDbHelper.getWritableDatabase();

        ContentValues johnValues = new ContentValues();
        johnValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME, "John");
        johnValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME, "Doe");
        johnValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_STATUS, "New user");
        db.insert(AppDatabaseContract.AppDatabase.TABLE_NAME, null, johnValues);

        ContentValues janeValues = new ContentValues();
        janeValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME, "Jane");
        janeValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME, "Smith");
        janeValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_STATUS, "New user");
        db.insert(AppDatabaseContract.AppDatabase.TABLE_NAME, null, janeValues);
    }

    private void doCleanup() {
        List<String> firstNames = new ArrayList<String>();
        List<String> lastNames = new ArrayList<String>();

        SQLiteDatabase db = appDbHelper.getReadableDatabase();

        String[] projection = {
                AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME,
                AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME
        };
        String sortOrder = AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + " DESC";
        Cursor cursor = db.query(AppDatabaseContract.AppDatabase.TABLE_NAME, projection, null,
                null, null, null, sortOrder);

        cursor.moveToNext();
        while (!cursor.isAfterLast()) {
            String firstName = cursor.getString(cursor.getColumnIndex(
                    AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME));
            String lastName = cursor.getString(cursor.getColumnIndex(
                    AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME));

            firstNames.add(firstName);
            lastNames.add(lastName);

            cursor.moveToNext();
        }

        for (int i = 0; i < firstNames.size(); i++) {
            String firstName = firstNames.get(i);
            String lastName = lastNames.get(i);

            String selection = AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME +
                " LIKE ? AND " + AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + " LIKE ?";
            String[] selectionArgs = { firstName, lastName };
            db.delete(AppDatabaseContract.AppDatabase.TABLE_NAME, selection, selectionArgs);
        }
    }

    private void doRepeatedWrites(int numWrites) {
        SQLiteDatabase db = appDbHelper.getWritableDatabase();
        for (int i = 0; i < numWrites; i++) {
            doWritesHelper(db, "John", "Doe", "Updating status to " + i);
        }
    }

    private void doWrites() {
        SQLiteDatabase db = appDbHelper.getWritableDatabase();
        doWritesHelper(db, "John", "Doe", "My first post!");
    }

    private void doWritesHelper(SQLiteDatabase db, String firstName, String lastName, String status) {
        ContentValues userValues = new ContentValues();
        userValues.put(AppDatabaseContract.AppDatabase.COLUMN_NAME_STATUS, status);

        String selection = AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME + " LIKE ? AND " +
            AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + " LIKE ?";
        String[] selectionArgs = { firstName, lastName };
        db.update(AppDatabaseContract.AppDatabase.TABLE_NAME, userValues, selection, selectionArgs);
    }

    private void doReads() {
        SQLiteDatabase db = appDbHelper.getReadableDatabase();
        doReadsHelper(db, "John", "Doe");
        doReadsHelper(db, "Jane", "Smith");
    }

    private void doReadsHelper(SQLiteDatabase db, String firstName, String lastName) {
        String[] projection = {
                AppDatabaseContract.AppDatabase.COLUMN_NAME_STATUS
        };

        String selection = AppDatabaseContract.AppDatabase.COLUMN_NAME_FIRSTNAME + " =? AND " +
                AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + " = ?";

        String[] selectionArgs = { firstName, lastName };

        String sortOrder = AppDatabaseContract.AppDatabase.COLUMN_NAME_LASTNAME + " DESC";

        Cursor cursor = db.query(AppDatabaseContract.AppDatabase.TABLE_NAME, projection, selection,
                selectionArgs, null, null, sortOrder);

        cursor.moveToNext();
        while (!cursor.isAfterLast()) {
            String status = cursor.getString(cursor.getColumnIndex(
                    AppDatabaseContract.AppDatabase.COLUMN_NAME_STATUS));
            Log.i(TAG, firstName + " " + lastName + " status " + status);
            cursor.moveToNext();
        }
    }
}
