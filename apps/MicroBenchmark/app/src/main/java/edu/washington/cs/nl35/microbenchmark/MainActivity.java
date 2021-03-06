package edu.washington.cs.nl35.microbenchmark;

import android.os.StrictMode;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.ThreadPoolExecutor;

public class MainActivity extends AppCompatActivity {

    private enum FillMode {NETWORK, DISK, DUMMY_DATA}

    private static final String TAG = "MainActivity";

    private static final FillMode FILL_MODE = FillMode.DUMMY_DATA;
    private static final boolean SAVE_ARRAYS = false;
    private static final boolean LOG_FILL_TIMES = false;

    private static final String SERVER_HOSTNAME = "35.211.96.243";
    private static final int SERVER_PORT = 8000;

    private static final int NUM_ARRAYS = 200;
    private static final int ARRAY_SIZE = 256 * 1024;

    private static final long FOREGROUND_SLEEP_TIME = 200; // milliseconds
    private static final long BACKGROUND_SLEEP_TIME = 1000; // milliseconds

    private static final boolean WORKER_THREAD_ENABLED = true;
    private static final long ITERS_PER_ROUND = 100000;
    private static final long INT_OP_LOOPS_PER_ITER = 40;
    private static final double WORKING_SET_FRACTION = 0.10;
    private static final double OUTSIDE_WORKING_SET_CHANCE = 0;

    private List<int[]> arrays;
    private volatile boolean appInForeground;
    private volatile boolean workerThreadDone;
    private ExecutorService threadPoolExecutor;

    private class WorkerRunnable implements Runnable {
        @Override
        public void run() {
            int globalCounter = 0;

            while (!workerThreadDone) {
                long sleepTime;
                if (appInForeground) {
                    sleepTime = FOREGROUND_SLEEP_TIME;
                }
                else {
                    sleepTime = BACKGROUND_SLEEP_TIME;
                }

                try {
                    Thread.sleep(sleepTime);
                }
                catch (InterruptedException e) {
                    e.printStackTrace();
                }

                long startTimeMillis = System.nanoTime() / (1000 * 1000);
                for (int i = 0; i < ITERS_PER_ROUND; i++) {
                    int[] getTarget;
                    int[] putTarget;
                    if (((double)i) / ITERS_PER_ROUND < OUTSIDE_WORKING_SET_CHANCE) {
                        getTarget = arrays.get(i % NUM_ARRAYS);
                        putTarget = arrays.get((i + 1) % NUM_ARRAYS);
                    }
                    else {
                        getTarget = arrays.get(i % (int)(NUM_ARRAYS * WORKING_SET_FRACTION));
                        putTarget = arrays.get((i + 1) % (int)(NUM_ARRAYS * WORKING_SET_FRACTION));
                    }
                    int valA = getTarget[(i + globalCounter) % ARRAY_SIZE];
                    int valB = getTarget[((i + 1) + globalCounter) % ARRAY_SIZE];
                    for (int j = 0; j < INT_OP_LOOPS_PER_ITER; j++) {
                        valA = valA * valB + 1;
                        valB = valA * valB + 1;
                    }
                    putTarget[(i + globalCounter) % ARRAY_SIZE] = valA;
                    putTarget[((i + 1) + globalCounter) % ARRAY_SIZE] = valB;
                }
                long endTimeMillis = System.nanoTime() / (1000 * 1000);
                long durationMillis = endTimeMillis - startTimeMillis;
                Log.i(TAG, "Worker thread performed " + ITERS_PER_ROUND + " iterations in " + durationMillis + " ms");

                globalCounter++;
                if (globalCounter > ARRAY_SIZE) {
                    globalCounter = 0;
                }
            }
        }
    }

    private class LoadDataRunnable implements Runnable {

        @Override
        public void run() {
            try {
                Log.i(TAG, "Filling arrays using mode " + FILL_MODE.toString());
                if ((FILL_MODE == FillMode.NETWORK || FILL_MODE == FillMode.DUMMY_DATA)
                        && SAVE_ARRAYS) {
                    Log.i(TAG, "Loaded arrays will be saved to disk");
                }

                for (int i = 0; i < NUM_ARRAYS; i++) {
                    int[] array = new int[ARRAY_SIZE];
                    long startTime = System.nanoTime();
                    if (FILL_MODE == FillMode.NETWORK) {
                        fillArrayFromInternet(array);
                        if (SAVE_ARRAYS) {
                            saveArrayDataToDisk(array, i);
                        }
                    } else if (FILL_MODE == FillMode.DISK) {
                        loadArrayDataFromDisk(array, i);
                    } else { // FILL_MODE == FillMode.DUMMY_DATA
                        Arrays.fill(array, 42);
                        if (SAVE_ARRAYS) {
                            saveArrayDataToDisk(array, i);
                        }
                    }
                    long endTime = System.nanoTime();
                    double fillTimeMs = (double)(endTime - startTime) / (1000 * 1000);
                    arrays.add(array);

                    if (LOG_FILL_TIMES) {
                        Log.i(TAG, "Fill time for array " + i + ": " + fillTimeMs + " ms");
                    }

                    if (i == NUM_ARRAYS * WORKING_SET_FRACTION - 1) {
                        Log.i(TAG, getApplicationContext().getPackageName() + " finished loading working set");
                    }
                }

                Log.i(TAG, getApplicationContext().getPackageName() + " finished loading all arrays");

                if (WORKER_THREAD_ENABLED) {
                    workerThreadDone = false;
                    new Thread(new WorkerRunnable()).start();
                }
            }
            catch (Exception e) {
                handleException(e);
            }
        }
    }

    private void fillArrayFromInternet(int[] array) throws IOException {
        int arraySizeBytes = ARRAY_SIZE * 4;
        URL arrayDataURL = new URL("http://" + SERVER_HOSTNAME + ":" + SERVER_PORT + "/arraydata?size=" + arraySizeBytes);
        URLConnection connection = arrayDataURL.openConnection();
        connection.setConnectTimeout(2000);
        connection.setReadTimeout(2000);
        BufferedInputStream bufferedInput = new BufferedInputStream(connection.getInputStream());
        deserializeArray(bufferedInput, array);
        bufferedInput.close();
    }

    private File getArrayFile(int arrayNum) {
        String fileName = "array" + arrayNum;
        File file = new File(getApplicationContext().getFilesDir(), fileName);
        return file;
    }

    private void saveArrayDataToDisk(int[] array, int arrayNum) throws IOException {
        File file = getArrayFile(arrayNum);
        BufferedOutputStream bufferedOutput = new BufferedOutputStream(new FileOutputStream(file));
        serializeArray(array, bufferedOutput);
        bufferedOutput.close();
    }

    private void loadArrayDataFromDisk(int[] array, int arrayNum) throws IOException {
        File file = getArrayFile(arrayNum);
        BufferedInputStream bufferedInput = new BufferedInputStream(new FileInputStream(file));
        deserializeArray(bufferedInput, array);
        bufferedInput.close();
    }

    private void deserializeArray(BufferedInputStream bufferedInput, int[] array) throws IOException {
        int byteArraySize = ARRAY_SIZE * 4;
        byte[] byteArray = new byte[byteArraySize];
        long readStartTime = System.nanoTime();
        int totalBytesRead = 0;
        while (totalBytesRead < byteArraySize) {
            int bytesRead = bufferedInput.read(byteArray, totalBytesRead, byteArraySize - totalBytesRead);
            totalBytesRead += bytesRead;
        }
        long readEndTime = System.nanoTime();
        for (int i = 0; i < ARRAY_SIZE; i++) {
            byte byte1 = byteArray[i * 4];
            byte byte2 = byteArray[i * 4 + 1];
            byte byte3 = byteArray[i * 4 + 2];
            byte byte4 = byteArray[i * 4 + 3];
            array[i] = (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4;
        }
        long deserializeEndTime = System.nanoTime();
        if (LOG_FILL_TIMES) {
            double readTimeMs = (double)(readEndTime - readStartTime) / (1000 * 1000);
            double deserializeTimeMs = (double)(deserializeEndTime - readEndTime) / (1000 * 1000);
            double totalTimeMs = (double)(deserializeEndTime - readStartTime) / (1000 * 1000);
            Log.i(TAG, "deserializeArray() read time: " + readTimeMs
                    + " ms, deserialize time: " + deserializeTimeMs + " ms, total time: "
                    + totalTimeMs + " ms");
        }
    }

    private void serializeArray(int[] array, BufferedOutputStream bufferedOutput) throws IOException {
        byte[] byteArray = new byte[ARRAY_SIZE * 4];
        long serializeStartTime = System.nanoTime();
        for (int i = 0; i < ARRAY_SIZE; i++) {
            byte byte1 = (byte)(array[i] >> 24);
            byte byte2 = (byte)(array[i] >> 16);
            byte byte3 = (byte)(array[i] >> 8);
            byte byte4 = (byte)array[i];
            byteArray[i * 4] = byte1;
            byteArray[i * 4 + 1] = byte2;
            byteArray[i * 4 + 2] = byte3;
            byteArray[i * 4 + 3] = byte4;
        }
        long serializeEndTime = System.nanoTime();
        bufferedOutput.write(byteArray);
        long writeEndTime = System.nanoTime();
        if (LOG_FILL_TIMES) {
            double serializeTimeMs = (double)(serializeEndTime - serializeStartTime) / (1000 * 1000);
            double writeTimeMs = (double)(writeEndTime - serializeEndTime) / (1000 * 1000);
            double totalTimeMs = (double)(writeEndTime - serializeStartTime) / (1000 * 1000);
            Log.i(TAG, "serializeArray() serialize time: " + serializeTimeMs
                    + " ms, write time: " + writeTimeMs + " ms, total time: " + totalTimeMs
                    + " ms");
        }
    }

    /*
     * I need this explicit exception-handling code for dealing with exceptions in tasks submitted
     * to the ExecutorService because ThreadPoolExecutors swallow exceptions by default. Currently
     * this code just logs the exception and then closes the application.
     *
     * This StackOverflow question contains information about ThreadPoolExecutor exception handling:
     * https://stackoverflow.com/q/2554549.
     *
     * This StackOverflow question contains information about how to close an application
     * programmatically: https://stackoverflow.com/q/6330200.
     */
    private void handleException(Exception e) {
        Log.e(TAG, "Caught exception: " + e);
        Log.i(TAG, "Exiting application");
        finishAndRemoveTask();
        System.exit(1);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        arrays = new ArrayList<>();
        threadPoolExecutor = Executors.newSingleThreadExecutor();
        threadPoolExecutor.submit(new LoadDataRunnable());

        Log.i(TAG, getApplicationContext().getPackageName() + " onCreate finished");
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
