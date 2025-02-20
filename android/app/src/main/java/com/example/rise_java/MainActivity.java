package com.example.rise_java;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.Context;
import android.os.PowerManager;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.rise_java/battery_optimization";

    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
//        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
//                .setMethodCallHandler(
//                        (call, result) -> {
//                            if (call.method.equals("requestIgnoreBatteryOptimizations")) {
//                                boolean isIgnoringBatteryOptimizations = requestIgnoreBatteryOptimizations();
//                                if (isIgnoringBatteryOptimizations) {
//                                    result.success(true);
//                                } else {
//                                    result.error("BATTERY_OPTIMIZATION_ERROR", "Failed to request battery optimization exemption", null);
//                                }
//                            } else {
//                                result.notImplemented();
//                            }
//                        }
//                );
    }

//    private boolean requestIgnoreBatteryOptimizations() {
//        PowerManager powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            if (powerManager.isIgnoringBatteryOptimizations(getPackageName())) {
//                return true;
//            }
//        }
//
//        try {
//            Intent intent = new Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
//            intent.setData(Uri.parse("package:" + getPackageName()));
//            startActivity(intent);
//        } catch (Exception e) {
//            Log.e("MainActivity", "Failed to start battery optimization exemption intent", e);
//            return false;
//        }
//        return true;
//    }
}