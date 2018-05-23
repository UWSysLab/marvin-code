package edu.washington.cs.nl35.microbenchmark;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    private static final int NUM_ARRAYS = 200;
    private static final int ARRAY_SIZE = 256 * 1024;

    private List<int[]> arrays;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        arrays = new ArrayList<>();
        for (int i = 0; i < NUM_ARRAYS; i++) {
            int[] array = new int[ARRAY_SIZE];
            Arrays.fill(array, 42);
            arrays.add(array);
        }
        Log.i(TAG, "Finished creating arrays");
    }

    @Override
    protected void onResume() {
        super.onResume();
        Log.i(TAG, "onResume finished");
    }
}
