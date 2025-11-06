package com.fgtp.color_slide;

import io.flutter.embedding.android.FlutterActivity;
import com.facebook.FacebookSdk;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
    }
}
