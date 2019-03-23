package edu.washington.cs.nl35.memorywaster;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class AllocatorActivity extends BaseActivity {

    private class WorkerRunnable implements Runnable {

        private static final int SLEEP_TIME_MS = 1000;

        @Override
        public void run() {
            while(true) {
                walkBuckets(NUM_BUCKETS, 0, 1);
                sleepWithCatch(SLEEP_TIME_MS);
            }
        }

        private void sleepWithCatch(long millis) {
            try {
                Thread.sleep(millis);
            } catch (InterruptedException e) {
                Log.i(TAG, "Thread.sleep() call interrupted");
            }
        }
    }

    private static final String TAG = "AllocatorActivity";
    private static final byte INITIAL_VALUE = 42;

    private static final int NUM_BUCKETS = 10;
    private static final int ARRAY_SIZE = 4076;
    private static final int NUM_ARRAYS_PER_BUCKET = 5120;

    private static final int NUM_ELEMENTS_TO_TOUCH = 5;

    private List<List<byte[]>> bucketList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        createBuckets();
        new Thread(new WorkerRunnable()).start();
    }

    private void createBuckets() {
        for (int i = 0; i < NUM_BUCKETS; i++) {
            List<byte[]> bucket = new ArrayList<>();
            bucketList.add(bucket);
            for (int j = 0; j < NUM_ARRAYS_PER_BUCKET; j++) {
                byte[] array = new byte[ARRAY_SIZE];
                for (int k = 0; k < array.length; k++) {
                    array[k] = INITIAL_VALUE;
                }
                bucket.add(array);
            }
        }
    }

    /**
     * Visit the specified buckets and touch every array inside.
     * @param numBuckets the number of buckets to touch
     * @param startingBucketIndex the index of the bucket to start on
     * @param stride the difference between the index of the next and current bucket
     */
    private void walkBuckets(int numBuckets, int startingBucketIndex, int stride) {
        long total = 0;
        int currentBucketIndex = startingBucketIndex;
        for (int i = 0; i < numBuckets; i++) {
            List<byte[]> currentBucket = bucketList.get(currentBucketIndex);
            for (int j = 0; j < NUM_ARRAYS_PER_BUCKET; j++) {
                byte[] currentArray = currentBucket.get(j);
                for (int k = 0; k < NUM_ELEMENTS_TO_TOUCH; k++) {
                    total += currentArray[k];
                }
            }
            currentBucketIndex += stride;
            currentBucketIndex = currentBucketIndex % bucketList.size();
        }
        Log.i(TAG, "Walked buckets; total = " + total);
    }
}
