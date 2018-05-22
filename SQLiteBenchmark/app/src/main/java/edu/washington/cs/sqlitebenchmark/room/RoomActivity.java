package edu.washington.cs.sqlitebenchmark.room;

import android.arch.persistence.room.Room;
import android.os.AsyncTask;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import java.util.List;

import edu.washington.cs.sqlitebenchmark.R;

public class RoomActivity extends AppCompatActivity {
    private final static String TAG = "RoomActivity";

    AppDatabase db;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_room);

        db = Room.databaseBuilder(getApplicationContext(), AppDatabase.class,
                "AppDatabase").build();

        Button benchmarkButton = findViewById(R.id.benchmarkButton);
        benchmarkButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new AsyncTask<Void, Void, Void>() {

                    @Override
                    protected Void doInBackground(Void... params) {
                        doReads();
                        doRepeatedWrites(1000);
                        doReads();
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void result) {
                        Toast.makeText(getApplicationContext(), "Done with writes", Toast.LENGTH_SHORT).show();
                    }
                }.execute();
            }
        });

        Button prepDbButton = findViewById(R.id.prepDbButton);
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
    }

    private void doSetup() {
        User johnDoe = new User();
        johnDoe.firstName = "John";
        johnDoe.lastName = "Doe";
        johnDoe.status = "New user";
        db.userDao().insertUser(johnDoe);

        User janeSmith = new User();
        janeSmith.firstName = "Jane";
        janeSmith.lastName = "Smith";
        janeSmith.status = "New user";
        db.userDao().insertUser(janeSmith);
    }

    private void doReads() {
        List<String> statuses = db.userDao().getStatus("John", "Doe");
        for(String status : statuses) {
            Log.i(TAG, "John Doe status: " + status);
        }

        statuses = db.userDao().getStatus("Jane", "Smith");
        for(String status : statuses) {
            Log.i(TAG, "Jane Smith status: " + status);
        }
    }

    private void doWrites() {
        db.userDao().setStatus("John", "Doe", "My first post!");
    }

    private void doRepeatedWrites(int numWrites) {
        for (int i = 0; i < numWrites; i++) {
            db.userDao().setStatus("John", "Doe", "Updating status to " + i);
        }
    }

    private void doCleanup() {
        List<User> users = db.userDao().getAllUsers();
        for(User user : users) {
            db.userDao().deleteUser(user);
        }
    }
}
