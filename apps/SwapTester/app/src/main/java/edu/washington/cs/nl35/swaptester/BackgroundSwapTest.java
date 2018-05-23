package edu.washington.cs.nl35.swaptester;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import java.util.ArrayList;
import java.util.List;

public class BackgroundSwapTest extends AppCompatActivity {

    private static final String TAG = "BackgroundSwapTest";

    private List<TestObject> testObjectList;

    private void sleepWithChecks(long millis) {
        try {
            Thread.sleep(millis);
        }
        catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_background_swap_test);

        testObjectList = new ArrayList<>();

        Button button = findViewById(R.id.button2);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                testObjectList.clear();
                for (int i = 0; i < 200000; i++) {
                    TestObject derp = null;
                    try {
                        derp = new TestObject();
                    }
                    catch (OutOfMemoryError e) {
                        sleepWithChecks(200);
                    }
                    testObjectList.add(derp);
                }
                Log.i(TAG, "Done allocating objects");

                Log.i(TAG, "Starting background thread");
                new Thread() {
                    @Override
                    public void run() {
                        Log.i(TAG, "Starting background thread");
                        for (int i = 0; i < 4; i++) {
                            sleepWithChecks(10000);
                            Log.i(TAG, "Woke up from sleep");
                        }
                        Log.i(TAG, "Start touching objects");
                        long dummyVar = 0;
                        for (int i = 0; i < testObjectList.size(); i++) {
                            dummyVar += testObjectList.get(i).a1;
                        }
                        Log.i(TAG, "End touching objects");
                    }
                }.start();
            }
        });
    }
}
