package com.example.utilityhub

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ❌ Disable secure mode (allows screen mirroring)
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
