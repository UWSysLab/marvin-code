package edu.washington.cs.nl35.memorywaster;

import android.app.ActivityManager;
import android.content.ComponentCallbacks2;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

/**
 * Base activity that provides a memory statistics display. A child Activity should add
 * Views to its LinearLayout by calling addViewToLayout().
 */
public class BaseActivity extends AppCompatActivity implements ComponentCallbacks2 {

    private static final String TAG = "BaseActivity";

    private LinearLayout layout;

    private TextView heapSizeTextView;
    private TextView freeHeapSpaceTextView;
    private TextView memClassTextView;
    private TextView runtimeMaxMemTextView;
    private TextView availableMemTextView;
    private TextView thresholdTextView;
    private TextView totalMemTextView;

    private void updateStats() {
        ActivityManager activityManager = (ActivityManager)getSystemService(ACTIVITY_SERVICE);
        memClassTextView.setText("Memory class (MB): " + activityManager.getMemoryClass());

        Runtime runtime = Runtime.getRuntime();
        runtimeMaxMemTextView.setText("Runtime max RAM (MB): " + runtime.maxMemory() / 1048576L);
        heapSizeTextView.setText("Heap size (MB): " + runtime.totalMemory() / 1048576L);
        freeHeapSpaceTextView.setText("Free heap space (MB): " + runtime.freeMemory() / 1048576L);

        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        activityManager.getMemoryInfo(memoryInfo);
        availableMemTextView.setText("Available system RAM (MB): " + memoryInfo.availMem/ 1048576L);
        thresholdTextView.setText("System low mem threshold (MB): " + memoryInfo.threshold / 1048576L);
        totalMemTextView.setText("System total RAM (MB): " + memoryInfo.totalMem / 1048576L);
    }

    private String getAppName() {
        return getString(R.string.app_name);
    }

    protected void addViewToLayout(View view) {
        layout.addView(view);
    }

    public void onTrimMemory(int level) {
        /*
         * ComponentCallbacks2 constant values are:
         * TRIM_MEMORY_BACKGROUND = 40
         * TRIM_MEMORY_COMPLETE = 80
         * TRIM_MEMORY_MODERATE = 60
         * TRIM_MEMORY_RUNNING_CRITICAL = 15
         * TRIM_MEMORY_RUNNING_LOW = 10
         * TRIM_MEMORY_RUNNING_MODERATE = 5
         * TRIM_MEMORY_UI_HIDDEN = 20
         */
        Log.i(TAG, "Received onTrimMemory() callback: " + level);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i(TAG, getAppName() + " onCreate");

        layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);

        heapSizeTextView = new TextView(this);
        freeHeapSpaceTextView = new TextView(this);
        memClassTextView = new TextView(this);
        runtimeMaxMemTextView = new TextView(this);
        availableMemTextView = new TextView(this);
        thresholdTextView = new TextView(this);
        totalMemTextView = new TextView(this);

        layout.addView(heapSizeTextView);
        layout.addView(freeHeapSpaceTextView);
        layout.addView(memClassTextView);
        layout.addView(runtimeMaxMemTextView);
        layout.addView(availableMemTextView);
        layout.addView(thresholdTextView);
        layout.addView(totalMemTextView);

        setContentView(layout);

        new Thread(new Runnable() {
            @Override
            public void run() {
                while(true) {
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            updateStats();
                        }
                    });
                }
            }
        }).start();
    }

    @Override protected void onStart() {
        super.onStart();
        Log.i(TAG, getAppName() + " onStart");
    }

    @Override protected void onRestart() {
        super.onRestart();
        Log.i(TAG, getAppName() + " onRestart");
    }

    @Override protected void onPause() {
        super.onPause();
        Log.i(TAG, getAppName() + " onPause");
    }

    @Override protected void onStop() {
        super.onStop();
        Log.i(TAG, getAppName() + " onStop");
    }

    @Override protected void onDestroy() {
        super.onDestroy();
        Log.i(TAG, getAppName() + " onDestroy");
    }
}
