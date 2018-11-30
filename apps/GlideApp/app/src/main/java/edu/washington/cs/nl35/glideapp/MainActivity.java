package edu.washington.cs.nl35.glideapp;

import android.graphics.drawable.Drawable;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.FutureTarget;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

public class MainActivity extends AppCompatActivity {

    private final String TAG = "MainActivity";
    private final String FILE_PREFIX = "image";
    private final String FILE_SUFFIX = ".png";
    private final int MAX_NUM_IMAGES = 500;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Button touchImageFilesButton = findViewById(R.id.touchImageFilesButton);
        touchImageFilesButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                touchFiles();
            }
        });

        Button imageLoopButton = findViewById(R.id.imageLoopButton);
        imageLoopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                EditText numImagesEditText = findViewById(R.id.numImagesEditText);
                String text = numImagesEditText.getText().toString();
                int numImages = Integer.parseInt(text);
                runImageLoopInBackground(numImages);
            }
        });
    }

    /**
     * Create a placeholder file for each image file holding a single byte of data. Run this method
     * once before copying the actual image files into the app folder and opening them (apparently
     * some Android security policy prevents apps from opening files in their local files directory
     * that they did not create).
     */
    private void touchFiles() {
        for (int i = 0; i < MAX_NUM_IMAGES; i++) {
            File file = new File(getApplicationContext().getFilesDir(), getFileName(i));
            try {
                FileOutputStream output = new FileOutputStream(file);
                output.write(4);
                output.close();
            } catch (FileNotFoundException e) {
                handleException(e);
            } catch (IOException e) {
                handleException(e);
            }
        }
    }

    private String getFileName(int index) {
        return FILE_PREFIX + index + FILE_SUFFIX;
    }

    private void runImageLoopInBackground(final int numImages) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                runImageLoop(numImages);
            }
        }).start();
    }

    private void runImageLoop(int numImages) {
        Log.i(TAG, "Starting image loop over " + numImages + " images");
        long startTime = System.nanoTime();
        for (int i = 0; i < numImages; i++) {
            File imageFile = new File(getApplicationContext().getFilesDir(), getFileName(i));
            FutureTarget<Drawable> futureTarget = Glide.with(this).load(imageFile).submit();
            try {
                final Drawable drawable = futureTarget.get();
            } catch (ExecutionException e) {
                handleException(e);
            } catch (InterruptedException e) {
                handleException(e);
            }
            Glide.with(this).clear(futureTarget);
        }
        long endTime = System.nanoTime();
        double elapsedTimeMs = (endTime - startTime) / (1000.0 * 1000.0);
        Log.i(TAG, "Image loop finished; elapsed time: " + elapsedTimeMs + " ms");
    }

    private void handleException(Exception e) {
        e.printStackTrace();
        finishAndRemoveTask();
        System.exit(1);
    }
}
