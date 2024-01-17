package com.rumina.esp_ble_prov_wifi;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import androidx.core.app.ActivityCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.PluginRegistry;

public class PermissionManager implements PluginRegistry.RequestPermissionsResultListener {
    private Boss boss;
    private PermissionCallback callback; // Replacing the Kotlin lambda with an interface
    private Map<Integer, PermissionCallback> callbacks = new HashMap<>();
    private int lastCallbackId = 0;

    public PermissionManager(Boss boss) {
        this.boss = boss;
    }

    // An interface to replace the Kotlin lambda
    public interface PermissionCallback {
        void onResult(boolean result);
    }

    // Custom getter for permissions
    public String[] getPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            return new String[]{Manifest.permission.BLUETOOTH_SCAN, Manifest.permission.BLUETOOTH_CONNECT};
        } else {
            return new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.BLUETOOTH, Manifest.permission.BLUETOOTH_ADMIN};
        }
    }

    public void ensure(PermissionCallback fCallback) {
        this.callback = fCallback;
        List<String> toRequest = new ArrayList<>();
        for (String p : getPermissions()) {
            if (ActivityCompat.checkSelfPermission(boss.getPlatformActivity(), p) != PackageManager.PERMISSION_GRANTED) {
                toRequest.add(p);
            }
        }
        if (!toRequest.isEmpty()) {
            ActivityCompat.requestPermissions(boss.getPlatformActivity(), toRequest.toArray(new String[0]), 0);
        } else {
            fCallback.onResult(true);
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        boss.d("permission result");
        if (this.callback != null) {
            callback.onResult(true);
        }
        return true;
    }
}
