package edu.washington.cs.nl35.microbenchmarktwo;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    private static final int ARRAY_SIZE = 256 * 1024;

    private static final int SLEEP_TIME_MS = 200;
    private static final int ITERS_PER_ROUND = 100000;
    private static final int INT_OP_LOOPS_PER_ITER = 99;
    private static final int OBJ_OP_LOOPS_PER_ITER = 101;

    private class WorkerRunnable implements Runnable {
        @Override
        public void run() {
            int[] arrayA = new int[ARRAY_SIZE];
            int[] arrayB = new int[ARRAY_SIZE];
            Arrays.fill(arrayA, 42);
            Arrays.fill(arrayB, 138);

            while (true) {
                try {
                    Thread.sleep(SLEEP_TIME_MS);
                }
                catch (InterruptedException e) {
                    e.printStackTrace();
                }

                long startTimeMillis = System.nanoTime() / (1000 * 1000);
                for (int i = 0; i < ITERS_PER_ROUND; i++) {
                    int valA = arrayA[0];
                    int valB = arrayB[0];
                    for (int j = 0; j < INT_OP_LOOPS_PER_ITER; j++) {
                        valA = valA * valB + 1;
                        valB = valA * valB + 1;
                    }
                    arrayA[0] = valA;
                    arrayB[0] = valB;
                    for (int k = 0; k < OBJ_OP_LOOPS_PER_ITER; k++) {
                        arrayA[k + 1] = arrayB[k];
                        arrayB[k + 1] = arrayA[k];
                    }
                }
                long endTimeMillis = System.nanoTime() / (1000 * 1000);
                long durationMillis = endTimeMillis - startTimeMillis;
                Log.i(TAG, "Worker thread performed " + ITERS_PER_ROUND + " iterations in " + durationMillis + " ms");
            }
        }
    }

        @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.i(TAG, getApplicationContext().getPackageName() + " onCreate finished");

        new Thread(new WorkerRunnable()).start();
    }
}
