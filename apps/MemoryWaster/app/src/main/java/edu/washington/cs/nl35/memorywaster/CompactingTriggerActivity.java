package edu.washington.cs.nl35.memorywaster;

import android.os.AsyncTask;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

/**
 * This Activity is intended to allocate objects in a way that will cause the compacting garbage
 * collector to trigger.
 */
public class CompactingTriggerActivity extends BaseActivity {

    private class SmallNode {
        public SmallNode prev;

        public int int1;
        public int int2;
        public double double1;
        public double double2;

        public SmallNode(SmallNode prev) {
            this.prev = prev;
            this.int1 = 42;
            this.int2 = 1337;
            this.double1 = 3.1415926535;
            this.double2 = 2.81;
        }
    }

    private class BigNode {
        public BigNode prev;

        public int int1;
        public int int2;
        public int int3;
        public int int4;
        public int int5;
        public int int6;
        public double double1;
        public double double2;
        public double double3;
        public double double4;
        public double double5;
        public double double6;

        public BigNode(BigNode prev) {
            this.prev = prev;
            this.int1 = 42;
            this.int2 = 1337;
            this.int3 = 42;
            this.int4 = 1337;
            this.int5 = 42;
            this.int6 = 1337;
            this.double1 = 3.1415926535;
            this.double2 = 2.81;
            this.double3 = 3.1415926535;
            this.double4 = 2.81;
            this.double5 = 3.1415926535;
            this.double6 = 2.81;
        }
    }

    private SmallNode smallRoot1;
    private SmallNode smallRoot2;
    private BigNode bigRoot;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Button allocSmallObjectsButton = new Button(this);
        allocSmallObjectsButton.setText("Alloc small objects");

        Button allocBigObjectsButton = new Button(this);
        allocBigObjectsButton.setText("Alloc big objects");

        Button deleteSmallObjectsButton = new Button(this);
        deleteSmallObjectsButton.setText("Delete small objects");
        deleteSmallObjectsButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View view) {
                smallRoot2 = null;
            }
        });

        addViewToLayout(allocSmallObjectsButton);
        addViewToLayout(allocBigObjectsButton);
        addViewToLayout(deleteSmallObjectsButton);

        allocSmallObjectsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new AsyncTask<Void, Void, Void>() {

                    @Override
                    protected Void doInBackground(Void... params) {
                        bigRoot = null;
                        smallRoot1 = null;
                        smallRoot2 = null;
                        SmallNode prevNode1 = new SmallNode(null);
                        SmallNode prevNode2 = new SmallNode(null);
                        for (int i = 0; i < 2400000; i++) {
                            SmallNode curNode1 = new SmallNode(prevNode1);
                            SmallNode curNode2 = new SmallNode(prevNode2);
                            prevNode1 = curNode1;
                            prevNode2 = curNode2;
                        }
                        smallRoot1 = prevNode1;
                        smallRoot2 = prevNode2;
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void result) {
                        Toast toast = Toast.makeText(CompactingTriggerActivity.this,
                                "Done allocating small objects", Toast.LENGTH_SHORT);
                        toast.show();
                    }
                }.execute();
            }
        });

        allocBigObjectsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new AsyncTask<Void, Void, Void>() {

                    @Override
                    protected Void doInBackground(Void... params) {
                        smallRoot2 = null;
                        BigNode prevNode = new BigNode(null);
                        for (int i = 0; i < 1200000; i++) {
                            BigNode curNode = new BigNode(prevNode);
                            prevNode = curNode;
                        }
                        bigRoot = prevNode;
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void result) {
                        Toast toast = Toast.makeText(CompactingTriggerActivity.this,
                                "Done allocating big objects", Toast.LENGTH_SHORT);
                        toast.show();
                    }
                }.execute();
            }
        });
    }
}
