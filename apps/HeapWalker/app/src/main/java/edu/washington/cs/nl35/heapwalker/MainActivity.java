package edu.washington.cs.nl35.heapwalker;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private class WorkerRunnable implements Runnable {

        private final int SLEEP_TIME_MS = 1000;

        // Values of state variable
        private final int JUST_CREATED = 0;
        private final int FIRST_FOREGROUND = 1;
        private final int FIRST_BACKGROUND = 2;
        private final int SECOND_FOREGROUND = 3;
        private final int DONE = 4;

        private int state;
        private Object lock;

        public WorkerRunnable() {
            state = JUST_CREATED;
            lock = new Object();
        }

        private int getStateLocked() {
            synchronized (lock) {
                return state;
            }
        }

        private void setStateLocked(int value) {
            synchronized(lock) {
                state = value;
            }
        }

        @Override
        public void run() {
            while (true) {
                int tempState = getStateLocked();

                if (tempState == FIRST_FOREGROUND
                        || tempState == FIRST_BACKGROUND) {
                    walkWorkingSet();
                    sleepWithCatch(SLEEP_TIME_MS);
                }
                else if (tempState == SECOND_FOREGROUND) {
                    walkMixWithTiming(30, 30);
                    setStateLocked(DONE);
                }
            }
        }

        public void onCreate() {
            setStateLocked(FIRST_FOREGROUND);
        }

        public void onStop() {
            if (getStateLocked() == FIRST_FOREGROUND) {
                setStateLocked(FIRST_BACKGROUND);
            }
        }

        public void onResume() {
            if (getStateLocked() == FIRST_BACKGROUND) {
                setStateLocked(SECOND_FOREGROUND);
            }
        }

        private void walkWorkingSet() {
            long total = 0;
            for (int i = 0; i < NUM_ARRAYS * WORKING_SET_FRAC; i++) {
                total += arrays.get(i)[0];
            }
            Log.i(TAG, "Walked working set; total = " + total);
        }

        /**
         *
         * @param totalArraysToTouch
         * @param nonWorkingSetTouchPeriod The number of working set arrays to touch between each
         *                                 touch of a non-working-set array.
         */
        private void walkMixWithTiming(int totalArraysToTouch, int nonWorkingSetTouchPeriod) {
            int workingSetStartIndex = 0;
            int nonWorkingSetStartIndex = (int)(NUM_ARRAYS * WORKING_SET_FRAC);

            int currentWorkingSetIndex = workingSetStartIndex;
            int currentNonWorkingSetIndex = nonWorkingSetStartIndex;
            int counter = 0;
            long total = 0;

            long startTimeNs = System.nanoTime();
            for (int i = 0; i < totalArraysToTouch; i++) {
                boolean touchNonWorkingSet = false;
                if (counter == nonWorkingSetTouchPeriod) {
                    counter = 0;
                    touchNonWorkingSet = true;
                }
                else {
                    counter++;
                }

                if (touchNonWorkingSet) {
                    total += arrays.get(currentNonWorkingSetIndex)[0];
                    currentNonWorkingSetIndex++;
                }
                else {
                    total += arrays.get(currentWorkingSetIndex)[0];
                    currentWorkingSetIndex++;
                }
            }
            long endTimeNs = System.nanoTime();
            double elapsedTimeMs = (endTimeNs - startTimeNs) / (1000.0 * 1000.0);
            Log.i(TAG, "Touched " + totalArraysToTouch + " arrays, touching "
                    + nonWorkingSetTouchPeriod
                    + " working set arrays between each non-working set array touch; total = "
                    + total);
            Log.i(TAG, "Elapsed time: " + elapsedTimeMs + " ms");
        }

        private void sleepWithCatch(long millis) {
            try {
                Thread.sleep(millis);
            } catch (InterruptedException e) {
                Log.i(TAG, "Thread.sleep() call interrupted");
            }
        }
    }

    private final String TAG = "MainActivity";
    private final int NUM_ARRAYS = 200;
    private final int ARRAY_SIZE = 1024 * 1024;
    private final double WORKING_SET_FRAC = 0.1;

    private WorkerRunnable worker;
    private List<byte[]> arrays;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        arrays = new ArrayList<>();
        for (int i = 0; i < NUM_ARRAYS; i++) {
            byte[] byteArray = new byte[ARRAY_SIZE];
            for (int j = 0; j < byteArray.length; j++) {
                byteArray[j] = 42;
            }
            arrays.add(byteArray);
        }

        worker = new WorkerRunnable();
        new Thread(worker).start();

        worker.onCreate();
    }

    @Override
    protected void onStop() {
        super.onStop();
        worker.onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();
        worker.onResume();
    }
}
