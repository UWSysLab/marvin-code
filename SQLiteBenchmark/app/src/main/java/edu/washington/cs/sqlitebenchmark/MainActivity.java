package edu.washington.cs.sqlitebenchmark;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import edu.washington.cs.sqlitebenchmark.room.RoomActivity;
import edu.washington.cs.sqlitebenchmark.sqlite.SQLiteActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button roomButton = findViewById(R.id.roomButton);
        roomButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent roomIntent = new Intent(MainActivity.this, RoomActivity.class);
                startActivity(roomIntent);
            }
        });

        Button sqliteButton = findViewById(R.id.sqliteButton);
        sqliteButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent sqliteIntent = new Intent(MainActivity.this, SQLiteActivity.class);
                startActivity(sqliteIntent);
            }
        });
    }
}
