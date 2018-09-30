package edu.washington.cs.nl35.swaptester;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class FreeTest extends AppCompatActivity {

    private static final String TAG = "FreeTest";

    private static final int ARRAY_SIZE = 256 * 1024;

    private List<int[]> list1;
    private List<int[]> list2;

    private void sleepWithChecks(long millis) {
        try {
            Thread.sleep(millis);
        }
        catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    private void addToList(List<int[]> list, int numArrays) {
        for (int i = 0; i < numArrays; i++) {
            int[] array = new int[ARRAY_SIZE];
            Arrays.fill(array, 42);
            list.add(array);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_free_test);

        list1 = new ArrayList<>();
        list2 = new ArrayList<>();

        addToList(list1, 100);

        Button allocateButton = findViewById(R.id.allocate_button);
        allocateButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (list2.size() > 0) {
                    Log.e(TAG, "list2 is not empty! Skipping allocation");
                }
                else {
                    Log.i(TAG, "Allocating arrays into list2");
                    addToList(list2, 100);
                }
            }
        });

        Button freeButton = findViewById(R.id.free_button);
        freeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Freeing arrays from list2");
                list2.clear();
            }
        });
    }
}
