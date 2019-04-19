package edu.washington.cs.nl35.memorywaster;

import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * A copy of AllocatorActivity that allocates 4KB arrays in odd-numbered buckets and 1MB arrays in
 * even-numbered buckets.
 */
public class MixAllocatorActivity extends BaseActivity {
    /**
     * A workload that repeatedly deletes and recreates the first N buckets, with a short sleep
     * between deletion and recreation and a longer sleep between rounds.
     */
    private class RecreateSomeRunnable implements Runnable {
        private static final int BETWEEN_ACTIONS_SLEEP_TIME_MS = 1000;
        private static final int BETWEEN_ROUNDS_SLEEP_TIME_MS = 5 * 1000;

        private int numBuckets;

        public RecreateSomeRunnable(int numBuckets) {
            this.numBuckets = numBuckets;
        }

        @Override
        public void run() {
            while(true) {
                deleteBuckets(numBuckets, 0, 1);
                sleepWithCatch(BETWEEN_ACTIONS_SLEEP_TIME_MS);
                recreateBuckets(numBuckets, 0 , 1);
                sleepWithCatch(BETWEEN_ROUNDS_SLEEP_TIME_MS);
            }
        }
    }

    private static final String TAG = "MixAllocatorActivity";
    private static final byte INITIAL_VALUE = 42;
    private static final int PAGE_SIZE = 4096;

    private static final int NUM_BUCKETS = 22;
    private static final int ODD_BUCKET_ARRAY_SIZE = 4076;
    private static final int NUM_ARRAYS_PER_ODD_BUCKET = 2560;
    private static final int EVEN_BUCKET_ARRAY_SIZE = 1048576;
    private static final int NUM_ARRAYS_PER_EVEN_BUCKET = 10;

    private static final int NUM_BUCKETS_TO_RECREATE = 2;

    private List<List<byte[]>> bucketList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        createAllBuckets();
        Runnable workload = new RecreateSomeRunnable(NUM_BUCKETS_TO_RECREATE);
        new Thread(workload).start();
    }

    private void createAllBuckets() {
        for (int i = 0; i < NUM_BUCKETS; i++) {
            boolean bucketIsOdd = (i % 2 != 0);
            List<byte[]> bucket = createBucket(bucketIsOdd);
            bucketList.add(bucket);
        }
    }

    private List<byte[]> createBucket(boolean bucketIsOdd) {
        int numArraysPerBucket = NUM_ARRAYS_PER_EVEN_BUCKET;
        int arraySize = EVEN_BUCKET_ARRAY_SIZE;
        if (bucketIsOdd) {
            numArraysPerBucket = NUM_ARRAYS_PER_ODD_BUCKET;
            arraySize = ODD_BUCKET_ARRAY_SIZE;
        }

        List<byte[]> bucket = new ArrayList<>();
        for (int i = 0; i < numArraysPerBucket; i++) {
            byte[] array = new byte[arraySize];
            for (int j = 0; j < array.length; j += PAGE_SIZE) {
                array[j] = INITIAL_VALUE;
            }
            bucket.add(array);
        }
        return bucket;
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
            boolean bucketIsOdd = (i % 2 != 0);
            List<byte[]> bucket = createBucket(bucketIsOdd);
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
