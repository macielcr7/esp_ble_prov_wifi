package com.rumina.esp_ble_prov_wifi;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import android.content.Intent;
import android.util.Log;

public class EspBleProvWifiPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

    private static final String logTag = "EspBleProvWifiChannel";
    private final Boss boss = new Boss();
    private MethodChannel channel;
    private ActivityPluginBinding activityBinding;

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        Log.d(logTag, "onAttachedToEngine: " + binding);
        channel = new MethodChannel(binding.getBinaryMessenger(), "esp_ble_prov_wifi");
        channel.setMethodCallHandler(this);
        boss.attachContext(binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
        Log.d(logTag, "onDetachedFromEngine: " + binding);
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Log.d(logTag, "onMethodCall: " + call.method + " " + call.arguments());
        boss.call(call, result);
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        Log.d(logTag, "onAttachedToActivity: " + binding);
        init(binding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d(logTag, "onDetachedFromActivityForConfigChanges");
        if (activityBinding != null) {
            tearDown(activityBinding);
        }
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        Log.d(logTag, "onReattachedToActivityForConfigChanges: " + binding);
        init(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d(logTag, "onDetachedFromActivity");
        if (activityBinding != null) {
            tearDown(activityBinding);
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(logTag, "onActivityResult " + requestCode + " " + resultCode + " " + data);
        return false;
    }

    private void init(ActivityPluginBinding binding) {
        this.activityBinding = binding;
        binding.addActivityResultListener(this);
        boss.attachBinding(binding);
        boss.attachActivity(binding.getActivity());
    }

    private void tearDown(ActivityPluginBinding binding) {
        binding.removeActivityResultListener(this);
        boss.detachBinding(binding);
        this.activityBinding = null;
    }
}

