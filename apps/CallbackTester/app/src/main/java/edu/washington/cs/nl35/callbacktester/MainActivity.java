package edu.washington.cs.nl35.callbacktester;

import android.content.ComponentCallbacks2;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity implements ComponentCallbacks2 {

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    private final String TAG = "MainActivity";
    private final int NUM_ARRAYS = 200;
    private final int ARRAY_SIZE = 1024 * 1024;
    private final int LOOP_CONSTANT = 500;

    private List<byte[]> arrays;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Example of a call to a native method
        final TextView tv = (TextView) findViewById(R.id.textView);
        tv.setText(stringFromJNI());

        Log.i(TAG, "onCreate() called");

        arrays = new ArrayList<>();
        for (int i = 0; i < NUM_ARRAYS; i++) {
            arrays.add(new byte[ARRAY_SIZE]);
        }

        Button button = findViewById(R.id.button);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int sum = 0;
                for (int i = 0; i < NUM_ARRAYS; i++) {
                    sum += arrays.get(i)[0];
                }
                tv.setText("Sum is " + sum);
            }
        });

        Button button2 = findViewById(R.id.button2);
        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                for (int i = 0; i < NUM_ARRAYS; i++) {
                    arrays.get(i)[0] = (byte)(arrays.get(i)[0] + 1);
                }
            }
        });

        Button button3 = findViewById(R.id.button3);
        button3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                doLengthyOperation();
            }
        });

        Button button4 = findViewById(R.id.button4);
        button4.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, Activity2.class);
                startActivity(intent);
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        Log.i(TAG, "onStart() called");
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.i(TAG, "onPause() called");
        doLengthyOperation();
    }

    @Override
    protected void onSaveInstanceState(Bundle bundle) {
        super.onSaveInstanceState(bundle);
        Log.i(TAG, "onSaveInstanceState() called");
        doLengthyOperation();
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.i(TAG, "onStop() called");
        doLengthyOperation();
    }

    @Override
    public void onTrimMemory(int level) {
        Log.i(TAG, "onTrimMemory() called with level " + level);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "onDestroy() called");
    }

    private void doLengthyOperation() {
        long startTime = System.nanoTime();

        for (int i = 0; i  < LOOP_CONSTANT; i++) {
            for (int j = 0; j < LOOP_CONSTANT; j++) {
                for (int k = 0; k < LOOP_CONSTANT; k++) {
                    int arrayNum1 = i % NUM_ARRAYS;
                    int arrayNum2 = j % NUM_ARRAYS;
                    int arrayIndex = k % ARRAY_SIZE;
                    arrays.get(arrayNum1)[arrayIndex] = (byte)(arrays.get(arrayNum2)[arrayIndex] + 1);
                }
            }
        }

        long endTime = System.nanoTime();
        double elapsedTimeMs = (endTime - startTime) / (1000.0 * 1000.0);
        Log.i(TAG, "doLengthyOperation() took " + elapsedTimeMs + " ms");
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();
}
