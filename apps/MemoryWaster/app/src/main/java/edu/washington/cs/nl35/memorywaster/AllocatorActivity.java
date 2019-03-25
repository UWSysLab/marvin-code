package edu.washington.cs.nl35.memorywaster;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class AllocatorActivity extends BaseActivity {

    /**
     * A workload that performs the following actions repeatedly, with short sleeps in between each
     * action:
     * 1) Walk all buckets.
     * 2) Walk all buckets.
     * 3) Delete all even-numbered buckets.
     * 4) Recreate all even-numbered buckets.
     */
    private class WalkAndRecreateRunnable implements Runnable {
        private static final int SLEEP_TIME_MS = 1000;
        private static final int WALKS_PER_DELETE_RECREATE = 2;

        @Override
        public void run() {
            int counter = 0;

            while(true) {
                if (counter == WALKS_PER_DELETE_RECREATE) {
                    deleteBuckets(NUM_BUCKETS / 2, 0, 2);
                    sleepWithCatch(SLEEP_TIME_MS);
                    recreateBuckets(NUM_BUCKETS / 2, 0 , 2);
                    sleepWithCatch(SLEEP_TIME_MS);
                    counter = 0;
                }
                else {
                    walkBuckets(NUM_BUCKETS, 0, 1);
                    sleepWithCatch(SLEEP_TIME_MS);
                    counter++;
                }
            }
        }
    }

    /**
     * A workload that repeatedly deletes and recreates every fifth bucket, with a short sleep
     * between deletion and recreation and a longer sleep between rounds.
     */
    private class RecreateSomeRunnable implements Runnable {
        private static final int BETWEEN_ACTIONS_SLEEP_TIME_MS = 1000;
        private static final int BETWEEN_ROUNDS_SLEEP_TIME_MS = 10 * 1000;

        @Override
        public void run() {
            while(true) {
                deleteBuckets(NUM_BUCKETS / 5, 0, 5);
                sleepWithCatch(BETWEEN_ACTIONS_SLEEP_TIME_MS);
                recreateBuckets(NUM_BUCKETS / 5, 0 , 5);
                sleepWithCatch(BETWEEN_ROUNDS_SLEEP_TIME_MS);
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
        createAllBuckets();
        new Thread(new WalkAndRecreateRunnable()).start();
    }

    private void createAllBuckets() {
        for (int i = 0; i < NUM_BUCKETS; i++) {
            List<byte[]> bucket = createBucket();
            bucketList.add(bucket);
        }
    }

    private List<byte[]> createBucket() {
        List<byte[]> bucket = new ArrayList<>();
        for (int i = 0; i < NUM_ARRAYS_PER_BUCKET; i++) {
            byte[] array = new byte[ARRAY_SIZE];
            for (int j = 0; j < array.length; j++) {
                array[j] = INITIAL_VALUE;
            }
            bucket.add(array);
        }
        return bucket;
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
        Log.i(TAG, "Walked " + numBuckets + " buckets starting at " + startingBucketIndex
                + " with stride " + stride + "; total = " + total);
    }

    /**
     * Delete the specified buckets.
     * @param numBuckets the number of buckets to recreate
     * @param startingBucketIndex the index of the bucket to start on
     * @param stride the difference between the index of the next and current bucket
     */
    private void deleteBuckets(int numBuckets, int startingBucketIndex, int stride) {
        int currentBucketIndex = startingBucketIndex;
        for (int i = 0; i < numBuckets; i++) {
            bucketList.set(currentBucketIndex, null);
            currentBucketIndex += stride;
            currentBucketIndex = currentBucketIndex % bucketList.size();
        }
        Log.i(TAG, "Deleted " + numBuckets + " buckets starting at " + startingBucketIndex
                + " with stride " + stride);
    }

    /**
     * Recreate the specified buckets.
     * @param numBuckets the number of buckets to recreate
     * @param startingBucketIndex the index of the bucket to start on
     * @param stride the difference between the index of the next and current bucket
     */
    private void recreateBuckets(int numBuckets, int startingBucketIndex, int stride) {
        int currentBucketIndex = startingBucketIndex;
        for (int i = 0; i < numBuckets; i++) {
            List<byte[]> bucket = createBucket();
            bucketList.set(currentBucketIndex, bucket);
            currentBucketIndex += stride;
            currentBucketIndex = currentBucketIndex % bucketList.size();
        }
        Log.i(TAG, "Recreated " + numBuckets + " buckets starting at " + startingBucketIndex
                + " with stride " + stride);
    }

    private void sleepWithCatch(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            Log.i(TAG, "Thread.sleep() call interrupted");
        }
    }
}
