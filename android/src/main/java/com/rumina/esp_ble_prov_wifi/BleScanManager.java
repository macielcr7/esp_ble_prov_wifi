package com.rumina.esp_ble_prov_wifi;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.le.ScanResult;
import android.os.Build;

import androidx.annotation.RequiresApi;

import com.espressif.provisioning.listeners.BleScanListener;

import java.util.ArrayList;
import java.util.List;

public class BleScanManager extends ActionManager {

    public BleScanManager(Boss boss) {
        super(boss);
    }

    @SuppressLint("MissingPermission")
    @Override
    public void call(CallContext ctx) {
        boss.d("searchBleEspDevices: start");
        String prefix = ctx.arg("prefix");
        if (prefix == null) {
            return;
        }

        boss.getEspManager().searchBleEspDevices(prefix, new BleScanListener() {
            @Override
            public void scanStartFailed() {
                // TODO: Implement what should happen if the scan start fails
            }

            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
            @Override
            public void onPeripheralFound(BluetoothDevice device, ScanResult scanResult) {
                if (device == null || scanResult == null) {
                    return;
                }
                boss.getDevicesConnectors().put(device.getName(), new BleConnector(device, scanResult));
                Device dev = new Device(device.getName(), device.getAddress());
                boss.getDevices().put(device.getName(), dev);
            }

            @Override
            public void scanCompleted() {
                ctx.getResult().success(boss.devicesToJson().toString());
                boss.d("searchBleEspDevices: scanComplete");
            }

            @Override
            public void onFailure(Exception e) {
                // TODO: Implement what should happen on failure
            }
        });
    }
}
