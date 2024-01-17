package com.rumina.esp_ble_prov_wifi;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.le.ScanResult;
import android.os.Build;

import androidx.annotation.RequiresApi;

public class BleConnector {
    private BluetoothDevice device;
    private String primaryServiceUuid;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public BleConnector(BluetoothDevice device, ScanResult scanResult) {
        this.device = device;
        
        if (scanResult.getScanRecord() != null && scanResult.getScanRecord().getServiceUuids() != null && !scanResult.getScanRecord().getServiceUuids().isEmpty()) {
            this.primaryServiceUuid = scanResult.getScanRecord().getServiceUuids().get(0).toString();
        } else {
            this.primaryServiceUuid = "";
        }
    }

    // Getter methods
    public BluetoothDevice getDevice() {
        return device;
    }

    public String getPrimaryServiceUuid() {
        return primaryServiceUuid;
    }
}
