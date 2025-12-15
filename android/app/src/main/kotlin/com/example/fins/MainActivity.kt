package com.example.fins

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine 
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin 

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterLocalNotificationsPlugin.set\\'FlutterEngine\\' (flutterEngine)
    }
}
