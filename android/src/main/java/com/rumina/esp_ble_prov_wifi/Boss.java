package com.rumina.esp_ble_prov_wifi;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import com.espressif.provisioning.DeviceConnectionEvent;
import com.espressif.provisioning.ESPConstants;
import com.espressif.provisioning.ESPDevice;
import com.espressif.provisioning.ESPProvisionManager;
import com.google.gson.JsonArray;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.json.JSONArray;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class Boss {
    private static final String logTag = "EspBleProvWifi";

    // Method names as called from Flutter across the channel.
    private static final String scanBleMethod = "scanBleDevices";
    private static final String scanWifiMethod = "scanWifiNetworks";
    private static final String provisionWifiMethod = "provisionWifi";
    private static final String platformVersionMethod = "getPlatformVersion";

    // The available scanned BLE devices and WiFi networks
    private Map<String, Device> devices = new HashMap<>();
    private Map<String, BleConnector> devicesConnectors = new HashMap<>();
    private Set<Network> networks = new HashSet<>();

    // Managers performing the various actions
    private PermissionManager permissionManager = new PermissionManager(this);
    private BleScanManager bleScanner = new BleScanManager(this);
    private WifiScanManager wifiScanner = new WifiScanManager(this);
    private WifiProvisionManager wifiProvisioner = new WifiProvisionManager(this);

    private Context platformContext;
    private Activity platformActivity;
    private ESPDevice connectedDevice;

    public ESPProvisionManager getEspManager() {
        return ESPProvisionManager.getInstance(platformContext);
    }

    public Activity getPlatformActivity(){
        return platformActivity;
    }

    public Map<String, BleConnector> getDevicesConnectors() {
        return devicesConnectors;
    }

    public Map<String, Device> getDevices(){
        return devices;
    }

    public Set<Network> getNetworks() {
        return networks;
    }

    // Logging shortcuts
    public void d(String msg) {
        Log.d(logTag, msg);
    }

    public void e(String msg) {
        Log.e(logTag, msg);
    }

    public void i(String msg) {
        Log.i(logTag, msg);
    }

    public BleConnector connector(String deviceName) {
        return devicesConnectors.get(deviceName);
    }

    public void connect(BleConnector conn, String proofOfPossession, ConnectCallback onConnectCallback) {
        ESPDevice esp = getEspManager().createESPDevice(ESPConstants.TransportType.TRANSPORT_BLE, ESPConstants.SecurityType.SECURITY_1);
        EventBus.getDefault().register(new Object() {
            @Subscribe(threadMode = ThreadMode.MAIN)
            public void onEvent(DeviceConnectionEvent event) {
                d("bus event " + event + " " + event.getEventType());
                if (event.getEventType() == ESPConstants.EVENT_DEVICE_CONNECTED) {
                    EventBus.getDefault().unregister(this);
                    esp.setProofOfPossession(proofOfPossession);
                    setConnectedDevice(esp);
                    onConnectCallback.onConnect(esp);
                }
            }
        });
        esp.connectBLEDevice(conn.getDevice(), conn.getPrimaryServiceUuid());
    }

    public void setConnectedDevice(ESPDevice newDevice) {
        ESPDevice lastDevice = connectedDevice;
        if (lastDevice != null) {
            if (newDevice != null && newDevice.getDeviceName().equals(lastDevice.getDeviceName())) {
                return;
            }
            lastDevice.disconnectDevice();
            connectedDevice = null;
        }
        connectedDevice = newDevice;
    }

    public void call(MethodCall call, Result result) {
        permissionManager.ensure(new PermissionManager.PermissionCallback() {
            @Override
            public void onResult(boolean isGranted) {
                CallContext ctx = new CallContext(call, result);
                switch (call.method) {
                    case platformVersionMethod:
                        getPlatformVersion(ctx);
                        break;
                    case scanBleMethod:
                        bleScanner.call(ctx);
                        break;
                    case scanWifiMethod:
                        wifiScanner.call(ctx);
                        break;
                    case provisionWifiMethod:
                        wifiProvisioner.call(ctx);
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        });
    }

    private void getPlatformVersion(CallContext ctx) {
        ctx.getResult().success("Android " + Build.VERSION.RELEASE);
    }

    // Additional methods for activity and context management
    public void attachActivity(Activity activity) {
        this.platformActivity = activity;
    }

    public void attachContext(Context context) {
        this.platformContext = context;
    }

    public void attachBinding(ActivityPluginBinding binding) {
        binding.addRequestPermissionsResultListener(permissionManager);
    }

    public void detachBinding(ActivityPluginBinding binding) {
        binding.removeRequestPermissionsResultListener(permissionManager);
    }

    // Define other necessary interfaces and classes
    public interface ConnectCallback {
        void onConnect(ESPDevice device);
    }

    public JSONArray devicesToJson() {
        JSONArray json = new JSONArray();
        for (Device device : devices.values()) {
            json.put(device.toJson());
        }
        return json;
    }

    public JSONArray networksToJson() {
        JSONArray json = new JSONArray();
        for (Network network : networks) {
            json.put(network.toJson());
        }
        return json;
    }
}
