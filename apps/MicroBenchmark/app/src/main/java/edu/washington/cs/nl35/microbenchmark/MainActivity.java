package edu.washington.cs.nl35.microbenchmark;

import android.os.StrictMode;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    private static final String SERVER_HOSTNAME = "128.208.6.189";
    private static final int SERVER_PORT = 9000;
    private static final boolean FILL_FROM_INTERNET = false;

    private static final int NUM_ARRAYS = 200;
    private static final int ARRAY_SIZE = 256 * 1024;

    private static final long FOREGROUND_SLEEP_TIME = 200; // milliseconds
    private static final long FOREGROUND_WORK_TIME = 200; // milliseconds
    private static final long BACKGROUND_SLEEP_TIME = 1000; // milliseconds
    private static final long BACKGROUND_WORK_TIME = 50; // milliseconds

    private static final double WORKING_SET_FRACTION = 0.10;
    private static final double OUTSIDE_WORKING_SET_CHANCE = 0.001;
    private static final double WRITE_CHANCE = 0.20;

    private static final long OPS_PER_LOG_MSG = 100000;

    private class WorkerRunnable implements Runnable {
        int total = 0;
        long opCounter = 0;

        private void doOperation() {
            boolean outsideWorkingSet = ThreadLocalRandom.current().nextDouble() < OUTSIDE_WORKING_SET_CHANCE;
            boolean doWrite = ThreadLocalRandom.current().nextDouble() < WRITE_CHANCE;

            int arrayIndex;
            if (outsideWorkingSet) {
                arrayIndex = ThreadLocalRandom.current().nextInt(NUM_ARRAYS);
            }
            else {
                arrayIndex = ThreadLocalRandom.current().nextInt((int)(NUM_ARRAYS * WORKING_SET_FRACTION));
            }
            int indexInsideArray = ThreadLocalRandom.current().nextInt(ARRAY_SIZE);
            int value = ThreadLocalRandom.current().nextInt();

            if (doWrite) {
                arrays.get(arrayIndex)[indexInsideArray] = value;
            }
            else {
                total += arrays.get(arrayIndex)[indexInsideArray];
            }

            opCounter++;
        }

        @Override
        public void run() {
            while (!workerThreadDone) {
                long workTime;
                long sleepTime;
                if (appInForeground) {
                    workTime = FOREGROUND_WORK_TIME;
                    sleepTime = FOREGROUND_SLEEP_TIME;
                }
                else {
                    workTime = BACKGROUND_WORK_TIME;
                    sleepTime = BACKGROUND_SLEEP_TIME;
                }

                try {
                    Thread.sleep(sleepTime);
                }
                catch (InterruptedException e) {
                    e.printStackTrace();
                }

                long startTimeMillis = System.nanoTime() / (1000 * 1000);
                boolean done = false;
                while (!done) {
                    for (int i = 0; i < 1000; i++) {
                        doOperation();
                    }
                    long currentTimeMillis = System.nanoTime() / (1000 * 1000);
                    if (currentTimeMillis - startTimeMillis > workTime) {
                        done = true;
                    }
                }

                Log.i(TAG, "Worker thread performed " + opCounter + " ops this round");
                opCounter = 0;
            }
        }
    }

    private List<int[]> arrays;
    private volatile boolean appInForeground;
    private volatile boolean workerThreadDone;

    private void fillArrayFromInternet(int[] array) {
        int arraySizeBytes = ARRAY_SIZE * 4;
        try {
            URL arrayDataURL = new URL("http://" + SERVER_HOSTNAME + ":" + SERVER_PORT + "/arraydata?size=" + arraySizeBytes);
            URLConnection connection = arrayDataURL.openConnection();
            connection.setConnectTimeout(2000);
            connection.setReadTimeout(2000);
            BufferedInputStream bufferedInput = new BufferedInputStream(connection.getInputStream());
            for (int j = 0; j < ARRAY_SIZE; j++) {
                byte byte1 = (byte) bufferedInput.read();
                byte byte2 = (byte) bufferedInput.read();
                byte byte3 = (byte) bufferedInput.read();
                byte byte4 = (byte) bufferedInput.read();
                array[j] = (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4;
            }
            bufferedInput.close();
        } catch (MalformedURLException e) {
            throw new RuntimeException(e);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        arrays = new ArrayList<>();

        if (FILL_FROM_INTERNET) {
            // Hack to allow networking on main thread. We want the networking calls to happen on
            // the main thread because we're using Activity lifecycle events to time app startup.
            // Based on this StackOverflow post: https://stackoverflow.com/a/9289190.
            StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitNetwork().build();
            StrictMode.setThreadPolicy(policy);
        }

        for (int i = 0; i < NUM_ARRAYS; i++) {
            int[] array = new int[ARRAY_SIZE];
            if (FILL_FROM_INTERNET) {
                fillArrayFromInternet(array);
            }
            else {
                Arrays.fill(array, 42);
            }
            arrays.add(array);
        }

        Log.i(TAG, "Finished creating arrays");
        appInForeground = true;
        workerThreadDone = false;

        new Thread(new WorkerRunnable()).start();
    }

    @Override
    protected void onResume() {
        super.onResume();
        appInForeground = true;
        Log.i(TAG, getApplicationContext().getPackageName() + " onResume finished");
    }

    @Override
    protected void onPause() {
        super.onPause();
        appInForeground = false;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        workerThreadDone = true;
    }
}
