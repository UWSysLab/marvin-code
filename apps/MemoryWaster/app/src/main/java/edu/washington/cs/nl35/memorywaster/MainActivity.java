package edu.washington.cs.nl35.memorywaster;

import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

/**
 * An activity that allocates a large ArrayList of small objects.
 */
public class MainActivity extends BaseActivity {

    private class DummyObject {
        public int int1;
        public int int2;
        public double double1;
        public double double2;

        public DummyObject() {
            int1 = 42;
            int2 = 1337;
            double1 = 3.1415926535;
            double2 = 2.81;
        }
    }

    private List<DummyObject> dummyObjects;

    private void createObjects(int numObjects) {
        dummyObjects.clear();
        for (int i = 0; i < numObjects; i++) {
            dummyObjects.add(new DummyObject());
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        dummyObjects = new ArrayList<>();

        final EditText editText = new EditText(this);
        editText.setText("1000000");

        Button wasteMemoryButton = new Button(this);
        wasteMemoryButton.setText("Waste memory!");

        wasteMemoryButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new AsyncTask<Integer, Integer, Void>() {

                    @Override
                    protected Void doInBackground(Integer... integers) {
                        int numObjects = integers[0];
                        createObjects(numObjects);
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void result) {
                        Toast toast = Toast.makeText(MainActivity.this, "Done", Toast.LENGTH_SHORT);
                        toast.show();
                    }
                }.execute(Integer.parseInt(editText.getText().toString()));
            }
        });

        addViewToLayout(editText);
        addViewToLayout(wasteMemoryButton);

        // hack to fill up memory on startup without clicking button
        new Thread(new Runnable() {
            @Override
            public void run() {
                createObjects(4000000);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast toast = Toast.makeText(MainActivity.this,
                                "Done making initial objects", Toast.LENGTH_SHORT);
                        toast.show();
                    }
                });
            }
        }).start();
    }
}
