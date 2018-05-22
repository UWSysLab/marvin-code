package edu.washington.cs.nl35.swaptester;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import java.lang.ref.WeakReference;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    private TestObject testObject;
    private boolean[] testBooleanArray;
    private String testString;
    private WeakReference<TestObject> weakRef;
    private boolean[] testBooleanArray2;

    public native void setGlobalRef();
    public native boolean readGlobalRef();
    public native boolean readLocalRef();

    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        testObject = new TestObject();
        TestObjectOmega testObject2 = new TestObjectOmega();
        TestObjectPrime testObject3 = new TestObjectPrime();
        testObject.next = testObject2;
        testObject2.next = testObject3;
        testObject2.a1 = 421396;

        weakRef = new WeakReference<TestObject>(testObject2);

        testBooleanArray = new boolean[13000];
        testBooleanArray[0] = true;

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 2000; i++) {
            sb.append("a");
        }
        testString = sb.toString();

        Button readObjectButton = findViewById(R.id.read_button);
        readObjectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.i(TAG, "TestObjectOmega a1 value: " + testObject.next.a1);
            }
        });

        Button deleteObjectButton = findViewById(R.id.delete_button);
        deleteObjectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                testObject.next = null;
                Log.i(TAG, "Deleted TestObjectOmega");
            }
        });

        Button writeObjectButton = findViewById(R.id.write_button);
        writeObjectButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (testObject.next.a1 == 421396) {
                    testObject.next.a1 = 64;
                }
                else {
                    testObject.next.a1 = 421396;
                }
                Log.i(TAG, "Wrote to TestObjectOmega");
            }
        });

        Button readArrayButton = findViewById(R.id.read_array_button);
        readArrayButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Boolean array element 0 value: " + testBooleanArray[0]);
            }
        });

        Button writeArrayButton = findViewById(R.id.write_array_button);
        writeArrayButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Writing to boolean array");
                testBooleanArray[0] = !testBooleanArray[0];
            }
        });

        Button readStringButton = findViewById(R.id.read_string_button);
        readStringButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "String char 2 value: " + testString.charAt(2));
            }
        });

        Button readRefButton = findViewById(R.id.read_ref_button);
        readRefButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                TestObjectOmega obj = (TestObjectOmega)weakRef.get();
                Log.i(TAG, "Reading TestObjectOmega a1 value through ref: " + obj.a1);
            }
        });

        Button readJniGlobalRefButton = findViewById(R.id.read_jni_global_ref_button);
        readJniGlobalRefButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Reading global ref: " + readGlobalRef());
            }
        });

        Button setJniGlobalRefButton = findViewById(R.id.set_jni_global_ref_button);
        setJniGlobalRefButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Setting global ref");
                setGlobalRef();
            }
        });

        Button readJniLocalRefButton = findViewById(R.id.read_jni_local_ref_button);
        readJniLocalRefButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Reading local ref: " + readLocalRef());
            }
        });

        Button allocateArray2Button = findViewById(R.id.allocate_array_2_button);
        allocateArray2Button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.i(TAG, "Allocating another big boolean array");
                testBooleanArray2 = new boolean[13000];
            }
        });
    }
}
