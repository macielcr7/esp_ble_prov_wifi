package com.rumina.esp_ble_prov_wifi;

import com.espressif.provisioning.ESPConstants;
import com.espressif.provisioning.ESPDevice;
import com.espressif.provisioning.listeners.ProvisionListener;

public class WifiProvisionManager extends ActionManager {

    public WifiProvisionManager(Boss boss) {
        super(boss);
    }

    @Override
    public void call(CallContext ctx) {
        boss.e("provisionWifi " + ctx.getCall().arguments);
        String ssid = ctx.arg("ssid");
        if (ssid == null) return;
        
        String passphrase = ctx.arg("passphrase");
        if (passphrase == null) return;
        
        String deviceName = ctx.arg("deviceName");
        if (deviceName == null) return;
        
        String proofOfPossession = ctx.arg("proofOfPossession");
        if (proofOfPossession == null) return;
        
        BleConnector conn = boss.connector(deviceName);
        if (conn == null) return;

        boss.connect(conn, proofOfPossession, new Boss.ConnectCallback() {


            @Override
            public void onConnect(ESPDevice esp) {
                boss.d("provision: start");
                esp.provision(ssid, passphrase, new ProvisionListener() {
                    @Override
                    public void createSessionFailed(Exception e) {
                        boss.e("wifiprovision createSessionFailed");
                    }

                    @Override
                    public void wifiConfigSent() {
                        boss.d("wifiConfigSent");
                    }

                    @Override
                    public void wifiConfigFailed(Exception e) {
                        boss.e("wifiConfiFailed " + e);
                        ctx.getResult().success(false);
                        boss.setConnectedDevice(null);
                    }

                    @Override
                    public void wifiConfigApplied() {
                        boss.d("wifiConfigApplied");
                    }

                    @Override
                    public void wifiConfigApplyFailed(Exception e) {
                        boss.e("wifiConfigApplyFailed " + e);
                        ctx.getResult().success(false);
                        boss.setConnectedDevice(null);
                    }

                    @Override
                    public void provisioningFailedFromDevice(ESPConstants.ProvisionFailureReason failureReason) {
                        boss.e("provisioningFailedFromDevice " + failureReason);
                        ctx.getResult().success(false);
                        boss.setConnectedDevice(null);
                    }

                    @Override
                    public void deviceProvisioningSuccess() {
                        boss.d("deviceProvisioningSuccess");
                        ctx.getResult().success(true);
                        boss.setConnectedDevice(null);
                    }

                    @Override
                    public void onProvisioningFailed(Exception e) {
                        boss.e("onProvisioningFailed");
                        ctx.getResult().success(false);
                        boss.setConnectedDevice(null);
                    }
                });
            }
        });
    }
}
